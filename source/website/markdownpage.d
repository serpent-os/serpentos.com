/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * website.markdownpage
 *
 * Encapsulation of hugo documents
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */
module website.markdownpage;

import std.datetime.systime;
import std.mmfile;
import std.regex;
import vibe.d;
import dyaml;
import arsd.dom;
import std.range : take;
import std.algorithm : each;

/**
 * Hugo document separation regex.
 */
private static auto metaRe = ctRegex!(`\-\-\-([\s\S]*)^\-\-\-([\s\S]*)`, [
        'g', 'm'
        ]);

/**
 * Access metaRe groups
 */
private static enum DocumentGroup
{
    Meta = 1,
    Contents = 2,
}

/**
 * Create a new MarkdownPage from the given input file
 *
 * This is provided solely as a compatibility means with
 * hugo and allows us to load all of the old hugo content
 * into the site. Yay.
 */
public final class MarkdownPage
{
    /**
     * Construct a new MarkdownPage
     */
    this() @safe
    {
        settings = new MarkdownSettings();
        settings.flags = MarkdownFlags.backtickCodeBlocks
            | MarkdownFlags.figures | MarkdownFlags.tables;
    }

    /**
     * Title property
     *
     * Returns: string title
     */
    pure @property string title() @safe @nogc nothrow const
    {
        return _title;
    }

    /**
     * When was it created?
     *
     * Returns: Creation date+time
     */
    pure @property SysTime date() @safe @nogc nothrow const
    {
        return _creation;
    }

    /**
     * URL appropriate slug
     *
     * Returns: a slug formatted identifier
     */
    pure @property string slug() @safe @nogc nothrow const
    {
        return _slug;
    }

    /**
     * Displayable content
     *
     * Returns: Markdown content
     */
    pure @property string content() @safe @nogc nothrow const
    {
        return _content;
    }

    /**
     * Icon property
     * 
     * Returns: icon as set in yml
     */
    pure @property string icon() @safe @nogc nothrow const
    {
        return _icon;
    }

    /**
     * Load the page from a file
     */
    void loadFile(in string filename) @safe
    {
        scope map = () @trusted { return new MmFile(filename); }();
        auto data = () @trusted { return cast(string) map[0 .. $]; }();
        auto ret = matchFirst(data, metaRe);
        enforceHTTP(!ret.empty, HTTPStatus.internalServerError);

        /* load the YAML */
        immutable meta = ret[DocumentGroup.Meta];
        auto metadata = Loader.fromString(meta).load();
        _title = metadata["title"].get!string;

        if ("icon" in metadata)
        {
            _icon = metadata["icon"].get!string;
        }

        /* Load it, and postfix the basic markdown */
        _content = filterMarkdown(ret[DocumentGroup.Contents], settings);
        fixMarkdown();
    }

private:

    /**
     * Fix the markdown returned from filterMarkdown, pipe
     * it through arsd.dom and sanitize it for inclusion in our site
     */
    void fixMarkdown() @safe
    {
        import std.stdio : writeln;

        auto newText = "<!DOCTYPE html><html><body><div id=\"markdownFixed\">"
            ~ _content ~ "</div></body></html>";
        Document doc = () @trusted { return new Document(newText, false, false); }();
        fixTables(doc);
        _content = () @trusted {
            return doc.getElementById("markdownFixed").toString;
        }();
    }

    /**
     * Fix all the tables in the document to work properly
     *
     * Fix row[0] in any table to be <thead> - add the correct
     * style classes.
     */
    void fixTables(scope Document doc) @safe
    {
        () @trusted {
            /* Fix tables. */
            foreach (ref table; doc.getElementsByTagName("table"))
            {
                /* Convert first <TR> into a <THEAD> */
                table.getElementsByTagName("tr").take(1).each!((row) => row.tagName = "thead");

                /* Add missing classes */
                static foreach (clz; [
                        "table", "table-responsive", "border", "shadow-sm",
                        "rounded"
                    ])
                {
                    table.addClass(clz);
                }

                /* Remove alignment hacks from td */
                table.getElementsByTagName("td").each!((td) => td.removeAttribute("align"));
            }
        }();
    }

    MarkdownSettings settings;
    string _title;
    SysTime _creation;
    string _slug;
    string _content;
    string _icon = "";
}

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

import arsd.dom;
import dyaml;
import std.algorithm : each;
import std.datetime.systime;
import std.mmfile;
import std.process;
import std.range : take;
import std.regex;
import vibe.d;

/**
 * Hugo document separation regex.
 */
private static auto metaRe = ctRegex!(`\-\-\-([\s\S]*?)^\-\-\-$([\s\S]*)`, ['m']);

private static auto codeRe = ctRegex!("^```([\\w]+)$", ['g', 'm']);

/**
 * In-document comments, remove *prior* to processing
 */
private static auto commentRe = ctRegex!(`(<!\-\-\-[\s\S]*?\-\-\->)`, ['m']);

/**
 * Inline hugo style command, i.e {{<figure_screenshot_one args=*}}
 */
private static auto inlineCommandRe = ctRegex!(
        `\{\{\<([a-zA-Z_]+)[\s\S]*?([\s\S]*?)>\}\}`, ['g', 'm']);

/**
 * "=" separated key value pairs
 */
private static auto commandArgsRe = ctRegex!(`([a-zA-Z]+)[\s]*?=[\s]*?\"([\s\S]*?)\"`, [
        'g', 'm'
        ]);
private static enum CommandGroup
{
    Name = 1,
    Args = 2, /* Not always present */



}

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

    pure @property string featuredImage() @safe @nogc nothrow const
    {
        return _featuredImage;
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

        /* Force webp featured images! */
        if ("featuredImage" in metadata)
        {
            _featuredImage = metadata["featuredImage"].get!string;
            if (_featuredImage.endsWith(".png"))
            {
                _featuredImage = format!"%s.webp"(_featuredImage[0 .. $ - 4]);
                logWarn("%s: Forcibly changed featuredImage to webp", filename);
            }
        }

        _creation = metadata["date"].get!SysTime;

        _slug = format!"%d/%02d/%02d/%s"(_creation.year, _creation.month,
                _creation.day, _title.asSlug);

        /* Load it, and postfix the basic markdown */
        auto preMarkdown = ret[DocumentGroup.Contents];

        /* vibe.d screws up code handling badly w/ backticks.
           we temporarily insert lang=identifier for later processing.
         */
        preMarkdown = replaceAll(preMarkdown, codeRe, "```\nlang=$1");

        /* also need to remove in-document comments.. */
        preMarkdown = replaceAll(preMarkdown, commentRe, "");

        /* We do need to support these commands but not just yet */
        preMarkdown = replaceAll(preMarkdown, inlineCommandRe, "");

        auto postMarkdown = filterMarkdown(preMarkdown, settings);
        _content = postMarkdown;
        fixMarkdown();
    }

private:

    /**
     * Fix the markdown returned from filterMarkdown, pipe
     * it through arsd.dom and sanitize it for inclusion in our site
     */
    void fixMarkdown() @safe
    {
        auto newText = "<!DOCTYPE html><html><body><div id=\"markdownFixed\">"
            ~ _content ~ "</div></body></html>";
        Document doc = () @trusted { return new Document(newText, false, false); }();
        fixTables(doc);
        syntaxHighlight(doc);
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

    /**
     * For every <pre><code> we find, smexify it.
     */
    void syntaxHighlight(scope Document doc) @trusted
    {
        foreach (elem; doc.getElementsByTagName("pre"))
        {
            bool found;
            foreach (syn; elem.getElementsByTagName("code"))
            {
                string txt = syn.innerText;
                auto cmd = [
                    "chroma", "--html", "--html-only",
                    "--html-prevent-surrounding-pre"
                ];

                if (txt.startsWith("lang="))
                {
                    auto lines = txt.split("\n");
                    string[] lang = lines[0].split("=");
                    string langCode = lang[1];
                    txt = txt["lang=\n".length + langCode.length .. $];
                    cmd ~= ["-l", lang[1]];
                }

                auto p = pipeProcess(cmd, Redirect.all);
                p.stdin.writeln(txt);
                p.stdin.flush();
                p.stdin.close();
                enforceHTTP(p.pid.wait() == 0, HTTPStatus.internalServerError,
                        "Failed to render markdown");
                syn.innerRawSource = p.stdout.byLineCopy.join("\n");
                found = true;
            }
            if (found)
            {
                elem.removeClass("prettyprint");
                elem.addClass("chroma");
            }
        }
    }

    MarkdownSettings settings;
    string _title;
    SysTime _creation;
    string _slug;
    string _content;
    string _icon = "";
    string _featuredImage;
}

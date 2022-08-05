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

/**
 * Hugo document separation regex.
 */
private static auto metaRe = ctRegex!`\-\-\-((?s).*)\-\-\-((?s).*)`;

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
    this() @safe
    {
        settings = new MarkdownSettings();
        settings.flags = MarkdownFlags.forumDefault;
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
     * Load the page from a file
     */
    void loadFile(in string filename) @safe
    {
        scope map = () @trusted { return new MmFile(filename); }();
        auto data = () @trusted { return cast(string) map[0 .. $]; }();
        auto ret = matchFirst(data, metaRe);
        enforceHTTP(!ret.empty, HTTPStatus.internalServerError);

        _content = filterMarkdown(ret[DocumentGroup.Contents], settings);
    }

private:

    MarkdownSettings settings;
    string _title;
    SysTime _creation;
    string _slug;
    string _content;
}

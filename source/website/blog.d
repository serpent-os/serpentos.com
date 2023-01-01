/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.blog;

/**
 * website.blog
 *
 * Handle the blog part of the site
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

import vibe.d;
import moss.db.keyvalue;
import moss.db.keyvalue.errors;
import moss.db.keyvalue.interfaces;
import moss.db.keyvalue.orm;
import website.models;
import std.string : format;
import std.array : appender, array;
import diet.html;
import std.algorithm : filter, sort;

@path("/blog") public final class Blog
{

    /**
     * Configure blog for integration
     */
    @noRoute void configure(URLRouter root, Database appDB) @safe
    {
        this.appDB = appDB;
        root.registerWebInterface(this);
        preloadContent();
    }

    /**
     * Main blog listing
     */
    void index()
    {
        render!("blog/index.dt");
    }

    /**
     * Could've just done "*" but route matching can save DB thrashing
     */
    @path(":year/:month/:day/:slugPart") @method(HTTPMethod.GET) void article(
            string _year, string _month, string _day, string _slugPart) @safe
    {
        immutable slug = format!"blog/%s/%s/%s/%s"(_year, _month, _day, _slugPart);
        Post post;
        immutable err = appDB.view((in tx) => post.load(tx, slug));
        enforceHTTP(err.isNull, HTTPStatus.notFound, err.message);
        render!("blog/post.dt", post);
    }

    /**
     * Encode an RSS stream for the blog
     */
    @path("index.xml") @method(HTTPMethod.GET) @contentType("application/rss+xml")
    ubyte[] rssFeed() @safe
    {
        auto content = appender!string;
        Post[] posts;
        appDB.view((in tx) @safe {
            posts = () @trusted {
                return tx.list!Post
                    .filter!((p) => p.type == PostType.RegularPost)
                    .array;
            }();
            posts.sort!"a.tsCreated > b.tsCreated";
            /* Limit post count to 25 */
            posts = posts.length > 25 ? posts[0 .. 25] : posts;
            return NoDatabaseError;
        });
        content.compileHTMLDietFile!("blog/rss.dt", posts);
        return () @trusted { return cast(ubyte[]) content[]; }();
    }

private:

    void preloadContent() @safe
    {
        import std.file : dirEntries, SpanMode;
        import std.array : array;
        import std.algorithm : map;
        import website.markdownpage : MarkdownPage;
        import std.path : baseName;
        import std.string : split;
        import std.conv : to;

        auto pages = () @trusted {
            return dirEntries("content/blog", "*.md", SpanMode.shallow, false).map!(
                    (i) => cast(string) i.name.dup).array();
        }();

        /* Try to load and save them all into a transaction. */
        auto err = appDB.update((scope tx) @safe {
            foreach (page; pages)
            {
                auto mdPost = new MarkdownPage();
                mdPost.loadFile(page);
                /* Force a page name, ignoring conventional slug rules */
                auto tstamp = mdPost.date.toUnixTime;
                Post p = Post();
                p.slug = format!"blog/%s"(mdPost.slug);
                p.title = mdPost.title;
                p.tsCreated = tstamp;
                p.tsModified = tstamp;
                p.processedContent = mdPost.content;
                p.processedSummary = mdPost.summary;
                p.featuredImage = mdPost.featuredImage;
                p.author = mdPost.author;
                auto e = p.save(tx);
                if (!e.isNull)
                {
                    return e;
                }
            }
            return NoDatabaseError;
        });
        enforceHTTP(err.isNull, HTTPStatus.internalServerError, "preloadContent(): " ~ err.message);
    }

    Database appDB;
}

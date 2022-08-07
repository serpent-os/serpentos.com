/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.app;

/**
 * website.app
 *
 * Main application instance for the website
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

import vibe.d;
import moss.db.keyvalue;
import moss.db.keyvalue.errors;
import moss.db.keyvalue.interfaces;
import moss.db.keyvalue.orm;
import website.models;
import website.blog;
import website.rest;

/**
 * Main instance, state et all
 */
@path("/") public final class Website
{
    /**
     * Construct a new Website instance
     */
    @noRoute this()
    {
        /* Get the DB up and running */
        Database.open("lmdb://database", DatabaseFlags.CreateIfNotExists).match!((db) {
            appDB = db;
        }, (err) { throw new Exception(err.toString); });

        immutable err = appDB.update((scope tx) => tx.createModel!(Post, Tag));
        enforceHTTP(err.isNull, HTTPStatus.internalServerError,
                "Failed to create model: " ~ err.message);

        settings = new HTTPServerSettings();
        settings.bindAddresses = ["localhost"];
        settings.disableDistHost = true;
        settings.port = 4040;
        settings.serverString = "serpentos/website";
        settings.useCompressionIfPossible = true;
        settings.sessionIdCookie = "serpentos/session_id";

        router = new URLRouter();

        /* All static assets */
        fileSettings = new HTTPFileServerSettings();
        fileSettings.serverPathPrefix = "/static";
        router.get("/static/*", serveStaticFiles("static", fileSettings));

        router.registerWebInterface(this);
        auto blog = new Blog();
        blog.configure(router, appDB);
        preloadContent();

        auto rapi = new BaseAPI();
        rapi.configure(appDB, router);

        router.rebuild();
    }

    /**
     * Start the server
     */
    @noRoute void start()
    {
        listener = listenHTTP(settings, router);
    }

    /**
     * Stop the server
     */
    @noRoute void stop()
    {
        listener.stopListening();
        appDB.close();
    }

    /**
     * Render the main landing page
     */
    void index() @safe
    {
        render!"index.dt";
    }

    /**
     * Render a single top level page
     */

    @noRoute void showPage(HTTPServerRequest req, HTTPServerResponse res) @safe
    {
        import std.path : baseName;

        string page = req.path.baseName;
        Post post;
        immutable err = appDB.view((in tx) => post.load(tx, page));
        enforceHTTP(err.isNull, HTTPStatus.notFound, err.message);
        res.render!("page.dt", post, req);
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
            return dirEntries("content", "*.md", SpanMode.shallow, false).map!(
                    (i) => cast(string) i.name.dup).array();
        }();

        /* Try to load and save them all into a transaction. */
        auto err = appDB.update((scope tx) @safe {
            foreach (page; pages)
            {
                auto mdPost = new MarkdownPage();
                mdPost.loadFile(page);
                /* Force a page name, ignoring conventional slug rules */
                immutable pageName = page.baseName.split(".")[0].asSlug.to!string;
                auto tstamp = mdPost.date.toUnixTime;
                Post p = Post();
                p.slug = pageName;
                p.title = mdPost.title;
                p.tsCreated = tstamp;
                p.tsModified = tstamp;
                p.processedContent = mdPost.content;
                p.type = PostType.Page;
                auto e = p.save(tx);
                if (!e.isNull)
                {
                    return e;
                }
                router.get("/" ~ p.slug, (req, res) => showPage(req, res));
            }
            return NoDatabaseError;
        });
        enforceHTTP(err.isNull, HTTPStatus.internalServerError, "preloadContent(): " ~ err.message);

    }

    HTTPListener listener;
    HTTPServerSettings settings;
    HTTPFileServerSettings fileSettings;
    URLRouter router;
    Database appDB;
}

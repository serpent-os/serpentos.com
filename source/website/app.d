/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.app;

/**
 * website.app
 *
 * Main application instance for the website
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
import website.blog;
import website.rest;
import website.team;
import vibe.core.core : setTimer;

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
        settings.errorPageHandler = &onError;
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
        fileSettings.maxAge = 30.days;
        router.get("/static/*", serveStaticFiles("static", fileSettings));

        router.registerWebInterface(this);
        auto blog = new Blog();
        blog.configure(router, appDB);
        preloadContent();

        router.registerWebInterface(new Team());

        auto rapi = new BaseAPI();
        rapi.configure(appDB, router);
        router.get("*", &showPage);
    }

    /**
     * Handle error pages
     */
    @noRoute void onError(scope HTTPServerRequest req,
            scope HTTPServerResponse res, scope HTTPServerErrorInfo error) @safe
    {
        res.render!("error.dt", req, error);
    }

    /**
     * Start the server
     */
    @noRoute void start()
    {
        setTimer(3.seconds, &memoryHack, true);
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

    /**
     * vibe.d runs an idle timer to collect memory every 10 seconds
     * but we never see it run, so we must manually run the GC every
     * few seconds ourselves to prevent shitting bricks
     */
    void memoryHack() @trusted
    {
        import core.memory : GC;

        GC.collect();
    }

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

        static DatabaseResult pageLoader(scope Transaction tx, string page) @safe
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
            immutable err = p.save(tx);
            if (!err.isNull)
            {
                return err;
            }
            return NoDatabaseError;
        }

        DatabaseResult insertion(scope Transaction tx) @safe
        {
            foreach (p; pages)
            {
                immutable e = pageLoader(tx, p);
                if (!e.isNull)
                {
                    return e;
                }
            }
            return NoDatabaseError;
        }

        /* Try to load and save them all into a transaction. */
        auto err = appDB.update(&insertion);
        enforceHTTP(err.isNull, HTTPStatus.internalServerError, "preloadContent(): " ~ err.message);

    }

    HTTPListener listener;
    HTTPServerSettings settings;
    HTTPFileServerSettings fileSettings;
    URLRouter router;
    Database appDB;
}

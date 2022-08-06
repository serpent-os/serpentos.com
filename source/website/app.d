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

/**
 * Main instance, state et all
 */
public final class Website
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

        router.get("/", staticTemplate!"index.dt");
        router.get("/test", (req, res) {
            import website.markdownpage : MarkdownPage;

            auto page = new MarkdownPage();
            page.loadFile("content/about.md");
            res.render!("page.dt", page, req, res);
        });

        router.rebuild();
    }

    /**
     * Start the server
     */
    void start()
    {
        listener = listenHTTP(settings, router);
    }

    /**
     * Stop the server
     */
    void stop()
    {
        listener.stopListening();
        appDB.close();
    }

private:

    HTTPListener listener;
    HTTPServerSettings settings;
    HTTPFileServerSettings fileSettings;
    URLRouter router;
    Database appDB;
}

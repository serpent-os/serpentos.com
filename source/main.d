/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module main;

/**
 * main
 *
 * Main entry - handle emission of all assets
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

import vibe.d;
import website.generator;
import std.algorithm : canFind;

/** 
 * Main entry for the binary
 *
 * Params:
 *   args = runtime arguments
 */
void main(string[] args) @safe
{
    auto gen = new WebsiteGenerator(".", "output");
    gen.build();

    if (!args.canFind("--serve"))
    {
        return;
    }

    /* Serve generated content via HTTP due to file:// security policy */
    auto settings = new HTTPServerSettings();
    settings.port = 8080;
    settings.useCompressionIfPossible = true;
    auto router = new URLRouter();
    auto fileSettings = new HTTPFileServerSettings();
    fileSettings.maxAge = 30.days;
    fileSettings.serverPathPrefix = "/";
    fileSettings.options = HTTPFileServerOption.failIfNotFound;
    auto fileHandler = serveStaticFiles("output");
    router.get("*", fileHandler);
    listenHTTP(settings, router);
    runApplication();
}

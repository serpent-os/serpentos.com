/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * Module Name (use e.g. 'moss.core.foo.bar')
 *
 * Main entry to our web app
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module main;

import vibe.d;
import website.app;

/**
 * Main routine, do nothing.
 */
int main(string[] args)
{
    auto site = new Website();
    scope (exit)
    {
        site.stop();
    }
    site.start();
    return runApplication();
}

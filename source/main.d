/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module main;
/**
 * main
 *
 * Main entry to our web app
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

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

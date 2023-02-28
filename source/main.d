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
}

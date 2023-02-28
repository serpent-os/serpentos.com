/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * website.generator
 *
 * Ridiculously simple static site generator.
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

module website.generator;

import std.exception : enforce;
import std.file : exists, isDir, mkdirRecurse, rmdirRecurse;

/** 
 * Generate the refreshed website using the built-in diet
 * templates. Logically everything is either a Page or a Post,
 * and is rendered using the appropriate template.
 */
public final class WebsiteGenerator
{
    @disable this();

    /** 
     * Construct a new WebsiteGenerator
     *
     * Params:
     *   inputDirectory = Where we can find the root of the website
     *   outputDirectory = Where built assets go.
     */
    this(string inputDirectory, string outputDirectory) @safe
    {
        this.inputDirectory = inputDirectory;
        this.outputDirectory = outputDirectory;

        /* Sanity tests */
        enforce(inputDirectory.exists && inputDirectory.isDir, "inputDirectory does not exist");
        enforce(inputDirectory != outputDirectory, "Mangling occurs when inputDir == outputDir");
        if (outputDirectory.exists)
        {
            outputDirectory.rmdirRecurse();
            outputDirectory.mkdirRecurse();
        }
    }

    /** 
     * Build the website, and dump in the outputDirectory
     *
     * Throws: Spanners
     */
    void build() @safe
    {
        throw new Exception("not yet implemented");
    }

private:

    string inputDirectory;
    string outputDirectory;
}

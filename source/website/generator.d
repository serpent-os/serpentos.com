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
import std.file;
import website.models;
import std.path : buildPath, relativePath;
import std.parallelism : TaskPool;
import std.array : array;
import std.algorithm : sort, map;
import std.string : startsWith;
import website.markdownpage;
import vibe.d;

/** 
 * Private mapping type to solve the dual-context ldc issue
 */
private static struct LoadableEntry
{
    /** 
     * Relative to base tree
     */
    string relaPath;

    /** 
     * Real path for the entry
     */
    string path;
}

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

        contentPath = inputDirectory.buildPath("content");
        enforce(contentPath.exists, contentPath ~ " does not exist");
    }

    /** 
     * Build the website, and dump in the outputDirectory
     *
     * Throws: Spanners
     */
    void build() @safe
    {
        immutable tsStart = Clock.currTime();
        auto content = loadContent();
        immutable tsEnd = Clock.currTime();
        logInfo(format!"Loaded %s pages in %s"(content.length, tsEnd - tsStart));
    }

private:

    /** 
     * Preload all markdown pages into Post[] slice
     *
     * Returns: Array of content
     */
    Post[] loadContent() @safe
    {
        /* parallel processing */
        auto tp = new TaskPool();
        scope (exit)
        {
            tp.finish();
        }
        tp.isDaemon = false;

        auto inputTree = () @trusted {
            return contentPath.dirEntries("*.md", SpanMode.depth).map!((string s) {
                return LoadableEntry(s.relativePath(inputDirectory), s);
            }).array();
        }();

        auto pages = () @trusted { return tp.map!loadPage(inputTree).array; }();
        /* Newest first */
        pages.sort!"a.tsCreated > b.tsCreated";

        return pages;
    }

    /** 
     * Load a markdown page from the given path
     *
     * Params:
     *   postPath = Where we found the post
     * Returns: A Post model struct
     */
    static Post loadPage(LoadableEntry entry) @safe
    {
        auto page = new MarkdownPage();
        page.loadFile(entry.path);

        /* Convert/copy into model */
        Post model;
        model.type = entry.relaPath.startsWith("content/blog") ? PostType.RegularPost
            : PostType.Page;
        model.author = page.author;
        model.featuredImage = page.featuredImage;
        model.processedContent = page.content;
        model.processedSummary = page.summary;
        model.slug = page.slug;
        model.title = page.title;
        model.tsCreated = page.date.toUTC.toUnixTime;
        model.tsModified = model.tsCreated;
        return model;
    }

    string inputDirectory;
    string outputDirectory;
    string contentPath;
}

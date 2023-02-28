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
import std.path : buildPath, relativePath, baseName, asNormalizedPath, absolutePath;
import std.parallelism : TaskPool, parallel;
import std.array : array, appender, Appender;
import std.algorithm : sort, map;
import std.string : startsWith;
import website.markdownpage;
import vibe.d;
import std.conv : to;
import diet.html;

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

private static struct EmissionTraits
{
    enum htmlOutputStyle = HTMLOutputStyle.compact;
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
        auto tsStart = Clock.currTime();
        auto content = loadContent();
        auto tsEnd = Clock.currTime();
        logInfo(format!"Loaded %s pages in %s"(content.length, tsEnd - tsStart));

        tsStart = Clock.currTime();
        writeContent(content);
        tsEnd = Clock.currTime();
        logInfo(format!"Wrote %s pages in %s"(content.length, tsEnd - tsStart));
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
                return LoadableEntry(s.relativePath(inputDirectory).asNormalizedPath.to!string, s);
            }).array();
        }();

        auto pages = () @trusted { return tp.map!loadPage(inputTree).array; }();
        /* Newest first */
        pages.sort!"a.tsCreated > b.tsCreated";

        return pages;
    }

    /** 
     * Write all content to disk
     *
     * Params:
     *   pages = The processed pages
     */
    void writeContent(Post[] pages) @trusted
    {
        import std.file : write;

        static struct MockRequest
        {
            string path;
        }

        foreach (ref page; pages.parallel)
        {
            auto app = Appender!string();

            immutable pageOutputDir = outputDirectory.buildPath(page.slug);
            immutable pageOutputIndex = pageOutputDir.buildPath("index.html");
            /* Allow relative CSS imports */
            immutable relativeRoot = outputDirectory.absolutePath.relativePath(
                    pageOutputDir.absolutePath);

            pageOutputDir.mkdirRecurse();

            /* Set "current" page */
            auto req = MockRequest(format!"/%s"(page.slug));
            auto post = page;

            /* render using appropriate diet template */
            final switch (page.type)
            {
            case PostType.RegularPost:
                app.compileHTMLDietFile!("blog/post.dt",
                        EmissionTraits, relativeRoot, req, post);
                break;
            case PostType.Page:
                app.compileHTMLDietFile!("page.dt",
                        EmissionTraits, relativeRoot, req, post);
                break;
            }

            pageOutputIndex.write(app[]);
        }
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
        model.slug = model.type == PostType.RegularPost
            ? format!"blog/%s"(page.slug) : page.slug.baseName;
        model.title = page.title;
        model.tsCreated = page.date.toUTC.toUnixTime;
        model.tsModified = model.tsCreated;
        return model;
    }

    string inputDirectory;
    string outputDirectory;
    string contentPath;
}

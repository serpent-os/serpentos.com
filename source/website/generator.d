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

import diet.html;
import std.algorithm : each, map, sort;
import std.array : Appender, appender, array;
import std.conv : to;
import std.digest;
import std.digest.sha;
import std.exception : enforce;
import std.file;
import std.mmfile;
import std.mmfile;
import std.parallelism : parallel, TaskPool;
import std.path : absolutePath, asNormalizedPath, baseName, buildPath, dirName,
    extension, relativePath;
import std.range : chunks;
import std.stdio : File;
import std.string : startsWith;
import vibe.d;
import website.markdownpage;
import website.models;

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
 * Force compact emission of HTML
 */
private static struct EmissionTraits
{
    enum htmlOutputStyle = HTMLOutputStyle.compact;
}

/**
 * Abuse the use of `.req` querying within templates
 */
private static struct MockRequest
{
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

        outputDirectory.buildPath("static").mkdirRecurse();

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

        auto assets = installAssets();

        tsStart = Clock.currTime();
        writeContent(content, assets);
        tsEnd = Clock.currTime();
        logInfo(format!"Wrote %s pages in %s"(content.length, tsEnd - tsStart));

        tsStart = Clock.currTime();
        copyStatic();
        tsEnd = Clock.currTime();
        logInfo(format!"Copied static/ in %s"(tsEnd - tsStart));

        emitTemplates(content, assets);
    }

private:

    static auto computeSHA256(immutable(string) path) @trusted
    {
        scope mmfile = new MmFile(File(path, "rb"));
        auto contents = cast(ubyte[]) mmfile[0 .. $];
        auto sha = makeDigest!SHA256();
        contents.chunks(4 * 1024 * 1024).each!((b) => sha.put(b));
        auto ret = (toHexString(sha.finish()).toLower()).idup;
        mmfile.destroy!false;
        return ret;
    }

    /** 
     * Hash/merge required assets for uniqueness
     *
     * Returns: set of mutated hashed paths
     */
    string[string] installAssets() @safe
    {
        string[string] ret;
        static immutable inputs = [
            "tabler/css/tabler.min.css", "tabler/js/tabler.min.js",
            "tabler/tabler-sprite-nostroke.svg", "tabler/tabler-sprite.svg",
            "js/darkMode.js", "js/global.js", "js/mainPage.js", "js/posts.js",
            "js/sponsors.js"
        ];
        static foreach (inp; inputs)
        {
            ret[inp] = installAsset(inp);
        }
        return ret;
    }

    /** 
     * Install a local asset as a hashed file, preserving the extension
     *
     * Params:
     *   localPath = Path relative to the root, i.e. tabler/min.css
     * Returns: 
     */
    string installAsset(string localPath) @safe
    {
        string ext = localPath.extension;
        if (ext.empty)
        {
            ext = ".asset";
        }
        immutable asset = inputDirectory.buildPath(localPath);
        immutable hash = computeSHA256(asset);
        immutable id = format!"%s%s"(hash, ext);
        immutable outputPath = outputDirectory.buildPath("static", id);
        asset.copy(outputPath);
        return id;
    }

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
    void writeContent(Post[] pages, ref string[string] assets) @trusted
    {
        import std.file : write;

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
                        EmissionTraits, relativeRoot, req, post, assets);
                break;
            case PostType.Page:
                app.compileHTMLDietFile!("page.dt",
                        EmissionTraits, relativeRoot, req, post, assets);
                break;
            }

            pageOutputIndex.write(app[]);
        }
    }

    void copyStatic() @safe
    {
        auto staticSource = inputDirectory.buildPath("static");
        auto staticDest = outputDirectory.buildPath("static");
        copyRecurse(staticSource, staticDest);
    }

    static void copyRecurse(string inputPath, string outputPath) @trusted
    {
        import std.file : copy;

        foreach (ref DirEntry ent; inputPath.dirEntries(SpanMode.shallow))
        {
            immutable relaPath = ent.name.baseName;
            auto dest = outputPath.buildPath(relaPath);

            auto dirn = dest.dirName;
            dirn.mkdirRecurse();

            if (ent.linkAttributes.attrIsDir)
            {
                copyRecurse(ent.name, dest);
            }
            else if (ent.linkAttributes.attrIsFile)
            {
                ent.name.copy(dest);
            }
            else
            {
                throw new Exception(format!"Cannot handle path %s"(ent.path));
            }
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
            ? format!"blog/%s"(page.slug) : entry.relaPath.baseName[0 .. $ - 3];
        model.title = page.title;
        model.tsCreated = page.date.toUTC.toUnixTime;
        model.tsModified = model.tsCreated;
        return model;
    }

    /** 
     * Emit remaining templates, i.e. index, blog/index
     *
     */
    void emitTemplates(scope Post[] posts, ref string[string] assets) @safe
    {
        static struct ManualTemplate
        {
            string templateFile;
            string outputPath;
            string navPath;
        }

        static immutable manualTemplates = [
            ManualTemplate("index.dt", "index.html", "/"),
            ManualTemplate("team.dt", "team/index.html", "/team"),
            ManualTemplate("blog/index.dt", "blog/index.html", "/blog"),
            ManualTemplate("blog/rss.dt", "blog/index.xml", "/blog")
        ];

        static foreach (m; manualTemplates)
        {
            {
                immutable outputPath = outputDirectory.buildPath(m.outputPath);
                immutable dir = outputPath.dirName;
                if (!dir.exists)
                {
                    dir.mkdirRecurse();
                }
                immutable relativeRoot = outputDirectory.absolutePath.relativePath(
                        dir.absolutePath);
                auto app = appender!string;
                auto req = MockRequest(m.navPath);
                app.compileHTMLDietFile!(m.templateFile, EmissionTraits,
                        relativeRoot, req, posts, assets);
                outputPath.write(app[]);
            }
        }
    }

    /**
     * Emit the fake API
     */
    void emitAPI() @safe
    {

    }

    string inputDirectory;
    string outputDirectory;
    string contentPath;
}

/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * website.rest
 *
 * REST API
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

module website.rest.blog;

import vibe.d;
import moss.db.keyvalue;
import moss.db.keyvalue.orm;
import website.models.post;
import std.array : array;
import std.range : drop, take;
import std.algorithm : filter, sort, map;

/**
 * Strips our model down to send the minimal
 * amount of information via JSON API
 */
struct MiniPost
{
    string title;
    string summary;
    string featuredImage;
    uint64_t tsCreated;
    string slug;
    string author;
}

/**
 * Helper to wrap up an input slice and provide
 * pagination for it via an offset and fixed page size
 *
 * Params:
 *      T = Type to paginate
 */
struct Paginator(T)
{
    /**
     * Slice of T
     */
    alias TSlice = T[];

    /**
     * Sub storage
     */
    TSlice items;

    /**
     * How big is each page?
     */
    ulong pageSize = 6;

    /**
     * How many pages in this query?
     */
    ulong numPages;

    /**
     * Page numner?
     */
    ulong page;

    /**
     * Construct a new Paginator
     */
    this(TSlice fullItemSet, ulong offset = 0) @safe
    {
        if (!fullItemSet.empty)
        {
            numPages = fullItemSet.length / pageSize;
            page = offset;
        }
        items = fullItemSet.drop(offset * pageSize).take(pageSize).array();
    }
}

/**
 * The basic posts API for listing
 */
@path("api/v1/posts") public interface PostsAPIv1
{
    /**
     * List all of the posts
     */
    @path("list") @method(HTTPMethod.GET) Paginator!MiniPost list(
            @viaQuery("offset") ulong offset = 0)@safe;

}

/**
 * Stub to branch REST API from
 */
public final class PostsAPI : PostsAPIv1
{
    /**
     * Register the REST API
     */
    @noRoute void configure(Database appDB, URLRouter router)
    {
        router.registerRestInterface(this);
        this.appDB = appDB;
    }

    override Paginator!MiniPost list(ulong offset = 0) @safe
    {
        MiniPost[] storage;
        immutable ret = appDB.view((in tx) @safe {
            storage = tx.list!Post
                .filter!((p) => p.type == PostType.RegularPost)
                .map!((p) => MiniPost(p.title, p.processedSummary,
                    p.featuredImage, p.tsCreated, p.slug, p.author))
                .array();
            storage.sort!"a.tsCreated > b.tsCreated";
            return NoDatabaseError;
        });
        return Paginator!MiniPost(storage, offset);
    }

private:

    Database appDB;
}

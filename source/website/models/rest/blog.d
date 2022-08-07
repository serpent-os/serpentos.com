/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * website.rest
 *
 * REST API
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module website.rest.blog;

import vibe.d;
import moss.db.keyvalue;
import moss.db.keyvalue.orm;
import website.models.post;
import std.array : array;
import std.range : drop, take;
import std.algorithm : filter, sort;

struct Paginator(T)
{
    alias TSlice = T[];
    TSlice items;

    ulong pageSize = 4;
    ulong numPages;
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

@path("api/v1/posts") public interface PostsAPIv1
{
    /**
     * List all of the posts
     */
    @path("list") @method(HTTPMethod.GET) Paginator!Post list(@viaQuery("offset") ulong offset = 0)@safe;

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

    override Paginator!Post list(ulong offset = 0) @safe
    {
        Post[] storage;
        immutable ret = appDB.view((in tx) @safe {
            storage = tx.list!Post
                .filter!((p) => p.type == PostType.RegularPost)
                .array();
            storage.sort!"a.tsCreated > b.tsCreated";
            return NoDatabaseError;
        });
        return Paginator!Post(storage, offset);
    }

private:

    Database appDB;
}

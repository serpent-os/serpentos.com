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

module website.rest;

import vibe.d;
import moss.db.keyvalue;
import website.rest.blog;

@path("api/v1") public interface BaseAPIv1
{
    /**
     * Placeholder - return our software version
     */
    @path("version") @method(HTTPMethod.GET) string versionIdentifier() @safe @nogc nothrow const;
}

/**
 * Stub to branch REST API from
 */
public final class BaseAPI : BaseAPIv1
{
    /**
     * Register the REST API
     */
    @noRoute void configure(Database appDB, URLRouter router)
    {
        auto root = router.registerRestInterface(this);
        auto p = new PostsAPI();
        p.configure(appDB, root);
    }

    override string versionIdentifier() @safe @nogc nothrow const
    {
        return "0.0.1";
    }
}

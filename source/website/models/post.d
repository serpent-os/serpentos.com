/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.models.post;

/**
 * website.models.post
 *
 * Post model
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

import moss.db.keyvalue.orm;

public import std.datetime.systime;
public import std.stdint : uint64_t;

/**
 * A Post can either be a blog post or a genuine page.
 */
@Model public struct Post
{
    /**
     * Unique site wide identifier. Must not have a "/" style prefix.
     */
    @PrimaryKey string slug;

    /**
     * Tag IDs we're associated with
     */
    string[] tags;

    /**
     * Display title
     */
    string title;

    /**
     * Pre-rendered content
     */
    string processedContent;

    /**
     * Initial creation time
     */
    uint64_t tsCreated;

    /**
     * Last modification time
     */
    uint64_t tsModified;
}

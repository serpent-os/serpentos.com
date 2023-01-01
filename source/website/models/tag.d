/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.models.tag;

/**
 * website.models.tag
 *
 * Tag model
 *
 * Authors: Copyright © 2020-2023 Serpent OS Developers
 * License: Zlib
 */

import moss.db.keyvalue.orm;

/**
 * A Tag is used to categorise our content
 */
@Model public struct Tag
{
    /**
     * Unique string for the tag
     */
    @PrimaryKey string id;
}

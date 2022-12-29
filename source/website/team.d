/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

module website.team;

/**
 * website.team
 *
 * Handle team rendering / updating
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

import vibe.d;
import moss.db.keyvalue;
import moss.db.keyvalue.errors;
import moss.db.keyvalue.interfaces;
import moss.db.keyvalue.orm;
import website.models;

/**
 * Handle team rendering
 */
@path("/team") public final class Team
{
    /**
     * Render the team page
     */
    void index() @safe
    {
        render!"team.dt";
    }
}

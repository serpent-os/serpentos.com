/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * global.js
 *
 * Global helpers
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

window.addEventListener('DOMContentLoaded', function(ev) {
    /* Format all unix timestamps in the users local time */
    this.document.querySelectorAll('.format-unix-timestamp').forEach((element) => {
        var when = new Date(parseInt(element.innerText) * 1000).toLocaleDateString();
        element.innerText = when;
        element.classList.remove('d-none');
    });
});
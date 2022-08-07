/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * posts.js
 *
 * Dynamic inclusion of posts
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

/**
 * Hook up our post handling
 */
window.addEventListener('load', function(ev)
{
    refreshList();
});

/**
 * Placeholder of sorts to show while loading in the blogposts
 *
 * @returns The loading string to display
 */
function renderLoadingPosts()
{
    return `
<div class="empty">
    <div class="empty-icon">
        <div class="spinner spinner-border"></div>
    </div>
    <div class="empty-title">Loading blog posts..</div> 
    <div class="empty-subtitle text-muted">*puts down cup of tea*</div>
</div>`;
}

/**
 * Render an error message in a fun kinda way
 */
function renderError(error)
{
    return `
<div class="empty">
    <div class="empty-icon">
        <svg>
            <use xlink:href="/static/tabler-sprite-nostroke.svg#tabler-bug"></use>
        </svg>
    </div>
    <div class="empty-title">Aww crap</div> 
    <div class="empty-subtitle text-muted">${error.message}</div>
    <div class="empty-action"><a class="btn" href="javascript:refreshList();">Refresh..</a></div>
</div>`;
}
/**
 * Refresh the blog post listing
 */
function refreshList()
{
    const list = this.document.getElementById('recentPosts');
    list.innerHTML = renderLoadingPosts();
    fetch('/api/v1/blog/list', {
        'credentials': 'include'
    }).then((response) => {
        if (!response.ok)
        {
            throw new Error("Failed to fetch posts: " + response.statusText + " (status: " + response.status + ")");
        }
        return response.json();
    }).then((object) = {

    }).catch((error) => {
        list.innerHTML = renderError(error);
    })
}
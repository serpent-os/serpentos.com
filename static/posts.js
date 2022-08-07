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
 * Render a single post
 */
function renderPost(post)
{
    return `
<div class="col-6 col-md-6 col-12 p-2">
    <div class="card">
        <div class="card-img-top img-fluid img-responsive img-responsive-16x9" style="background-color: grey; background-image: url('https://serpentos.com/${post.featuredImage}'); background-repeat: no-repeat; background-position: cover;">
        </div>
        <div class="card-body">
            <div class="row d-flex">
                <div class="col-auto">
                    <span class="avatar">??</span>
                </div>
                <div class="col">
                    <div class="text-bold"><a class="text-reset stretched-link" href="/${post.slug}">${post.title}</a></div>
                    <div class="text-muted">Some summary...</div>
                </div>
            </div>
        </div>
    </div>
</div>
`;
}

/**
 * Refresh the blog post listing
 */
function refreshList()
{
    const list = this.document.getElementById('recentPosts');
    list.innerHTML = renderLoadingPosts();
    fetch('/api/v1/posts/list', {
        'method': 'GET',
        'credentials': 'include'
    }).then((response) => {
        if (!response.ok)
        {
            throw new Error("Failed to fetch posts: " + response.statusText + " (status: " + response.status + ")");
        }
        return response.json();
    }).then((object) => {
        let rawHTML = '';
        object.forEach((element) => {
            rawHTML += renderPost(element);
        });
        list.innerHTML = rawHTML;
    }).catch((error) => {
        list.innerHTML = renderError(error);
    })
}
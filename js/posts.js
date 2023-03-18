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

let buildTimestamp;
let svgAsset;

/**
 * Hook up our post handling
 */
window.addEventListener('load', function(ev)
{
    svgAsset = this.document.getElementById('tblr').getAttribute('value');
    buildTimestamp = this.document.getElementById('buildTimestamp').getAttribute('value');
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
            <use xlink:href="/static/${svgAsset}#tabler-bug"></use>
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
    const dom = new DOMParser().parseFromString(post.summary, "text/html");
    var when = new Date(post.tsCreated * 1000).toDateString();

    return `
<div class="col-6 col-md-6 col-12 p-2">
    <div class="card">
        <div class="card-body">
            <div class="row align-items-center">
                <div class="col">
                    <h3><a class="stretched-link" href="/${post.slug}">${post.title}</a></h3>
                </div>
                <div class="col-auto">
                    <small class="text-muted">${when}</small>
                </div>
            </div>
            <div class="row d-flex pt-2">
                <div class="col-3 col-md-3">
                    <div class="img-fluid img-thumbnail img-responsive img-responsive-16x9" style="background-color: grey; background-image: url('/static${post.featuredImage}'); background-repeat: no-repeat; background-position: cover;">
                    </div>
                </div>
                <div class="col"
                    <div>${dom.documentElement.textContent.substring(0, 200)}…</div>
                </div>
            </div>
        </div>
    </div>
</div>
`;
}

function renderPaginator(object)
{
    const pickers = Array.from({length: object.numPages}, (x, i) => i).map(elem => {
        if (object.page == elem)
        {
            return `<li class="page-item active"><a class="page-link" href="#paginator" onclick="event.preventDefault();">${elem + 1}</a></li>`;
        } else {
            return `<li class="page-item"><a class="page-link" href="#paginator" onclick="event.preventDefault(); refreshList(${elem}, true);">${elem + 1}</a></li>`
        }
    }).join("\n");
    const backIcon = `<svg class="icon"><use xlink:href="/static/tabler-sprite-nostroke.svg#tabler-chevron-left"></use></svg>`;
    const forwardIcon = `<svg class="icon"><use xlink:href="/static/tabler-sprite-nostroke.svg#tabler-chevron-right"></use></svg>`;
    const backElement = object.page > 0 ? 
        `<li class="page-item"><a class="page-link" href="#" onclick="event.preventDefault(); refreshList(${object.page - 1}, true);" tabindex="-1">${backIcon}</a></li>` :
        `<li class="page-item disabled"><a class="page-link" href="#" onclick="event.preventDefault();" tabindex="-1" aria-disabled="true">${backIcon}</a></li>`;
    const forwardElement = object.page <= object.numPages - 1 ? 
        `<li class="page-item"><a class="page-link" href="#" onclick="event.preventDefault(); refreshList(${object.page + 1}, true);" tabindex="-1">${forwardIcon}</a></li>` :
        `<li class="page-item disabled"><a class="page-link" href="#" onclick="event.preventDefault();" tabindex="-1" aria-disabled="true">${forwardIcon}</a></li>`;
    return `
<nav aria-label="Navigation of posts" class="justify-content-center">
    <ul class="pagination flex-wrap">
        ${backElement}
        ${pickers}
        ${forwardElement}
    </ul>
</nav>
`;
}

/**
 * Refresh the blog post listing
 */
function refreshList(offset = 0, jump = false)
{
    const list = this.document.getElementById('recentPosts');
    const paginator = this.document.getElementById('paginator');
    if (!jump)
    {
        list.innerHTML = renderLoadingPosts();
    }
    fetch(`/api/${buildTimestamp}/posts.${offset}.json`, {
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
        object.items.forEach((element) => {
            rawHTML += renderPost(element);
        });
        list.innerHTML = rawHTML;
        paginator.innerHTML = renderPaginator(object);
    }).catch((error) => {
        list.innerHTML = renderError(error);
    });
    return false;
}

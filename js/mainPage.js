/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * mainPage.js
 *
 * Dynamic features for landing page
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

/**
 * Hook up our post handling
 */
 window.addEventListener('load', function(ev)
 {
     refreshLatestNews();
 });
 
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
 
 /**
  * Refresh the latest news
  */
 function refreshLatestNews()
 {
     const list = this.document.getElementById('latestNews');
     fetch(`/api/v1/posts/list`, {
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
         object.items.slice(0, 2).forEach((element) => {
             rawHTML += renderPost(element);
         });
         list.innerHTML = rawHTML;
     }).catch((error) => {
         list.innerHTML = renderError(error);
     });
     return false;
 }
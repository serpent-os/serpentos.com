---
title: "Migrating to GitLab"
date: 2021-06-15T13:26:39+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/migrating-to-gitlab/Featured.webp"

---

Hot on the heels of yesterday's transition from IRC to Matrix, we're
revamping our infrastructure to further enable success for our project.

Recently we heard the company behind Phabricator is [winding down operations](https://admin.phacility.com/phame/post/view/11/phacility_is_winding_down_operations/).
We can't really complain, as we used it freely and really appreciated
the project while using it.

<!--more-->

{{<figure_screenshot_one image="migrating-to-gitlab/Featured" caption="Shiny new GitLab project">}}


Going forwards, we decided to collapse the disparity between our code hosting
solutions. A major requirement for us is a support for many repositories, namespace
nesting, and global overview of issues outside of a specific subproject or repository.

In our testing, only GitLab ticked all the boxes. As such, we've migrated
our GitHub projects over to our new, nicely organised, [GitLab home](https://gitlab.com/serpent-os).

I've switched our Phabricator instance to read-only, and imported all of our
projects, and most of the issues, to the new public GitLab project. It will
take a couple of days to get the migration completed, updating submodule URLs, etc,
but we've already archived all of our GitHub projects.

# Other Items

In keeping with naming consistency, the official Twitter account was renamed
to [Serpent_OS](https://twitter.com/Serpent_OS). Additionally, my shiny new
broadband connection will be installed on the 28th of this month, unlocking
further development powah.

Peter has been working on a messaging overhaul for the website, which will be
launched Fairly Soonish. After that, a visual update will follow. In parallel
to this, we'll be putting moss to work.

# Repurposing our sponsored server

[Fosshost](https://fosshost.org) kindly sponsored us very early on with a
server to host our Phabricator instance and downloads. For now we'll explicitly
repurpose it to be a high speed package and ISO origin for the mirror network,
to ensure constant access for clients. Huge thanks to Fosshost for the continued
sponsorship!

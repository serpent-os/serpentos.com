---
title: "Pedal to the Metal"
date: 2022-01-25T11:31:30Z
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/pedal-to-the-metal/Featured.webp"
---

Wow - what a roller coaster. The most recent development cycle has seen us really
begin to realise the potential of `moss` and `boulder`, our software management
and builder tooling. In fact, work has progressed so far that we're happy to
make something of a milestone announcement.. So happy in fact, I personally
wrote this post. (I know, right?)

<!--more-->


(TLDR; We're gonna build images for packaging now kthxbai)

{{<figure_screenshot_one image="pedal-to-the-metal/Featured" caption="Installing remote package and dependencies with moss">}}

# Release ... The Packages

We're a **highly** tool oriented project, and in fact, virtually every announcement
since our inception has been in relation to tooling. But.. aren't we also building
a Linux distribution..?

Despite the raw state of some of the tooling, we now feel we're at a point where
truly building the "OS" side of Serpent can happen. As it stands, we have a small
number of items to complete before we launch the build pipeline.

Here's the plan, quite simple, really. We're going to rapidly fix some last blockers
in enabling a pipeline to onboard contributors during the early stages of development
to form a proper feedback cycle for the package manager development. As such - we'll
be entering a parallel development phase where the distribution and package manager
will grow in tandem allowing us to rapidly build up.


# Images when?

Along with packages being available, we're going to soon be building preliminary
Serpent OS images. These are not meant for use in production or daily use in any
capacity and will be provided so that the developer community around Serpent OS
can begin implementing the distro itself. Anyone will be free to download and test
the images - just remember, they will eat your homework and are devcycle images
to figure out how to provide the final user friendly images :)

# The Mandatory Bullet Point List

Oh you have to have one of these. It's mandatory.

 - Finish `moss-container` integration with `boulder`
 - Add `boulder` configuration support to define *repositories for the build*
 - Add some internal scripting to construct and manage our GitLab recipe repos
 - Add a primitive binary repo indexing system until full variant available
 - Add automated builder for our recipes.
 - Get everyone packaging (:O)
 - Enable packagers by implementing features and solving moss/boulder issues.
 - Start chucking out installable images, for packaging and tooling validation.
 
Timescale? Fast as frackin possible. Welcome to our test launch party.

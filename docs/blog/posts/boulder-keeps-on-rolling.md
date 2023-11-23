---
title: "Boulder Keeps On Rolling"
date: 2021-07-27T16:05:23+11:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/boulder-keeps-on-rolling/Featured.webp"
---

Squirrelling away in the background has been some great changes to bring `boulder` closer to its full potential. Here's
a quick recap of some of the more important ones.

<!--more-->

{{<figure_screenshot_one image="boulder-keeps-on-rolling/Featured" caption="boulder hard at work">}}

# Key Changes to Boulder

 - Fixed a path issue that prevented manifests from being written for 32bit builds
 - Added keys to control where the tarballs are extracted to
   - This results in a greatly simplified setup stage when using multiple upstreams
 - More customizations to control the final c{,xx}flags exported to the build
 - Added a key to run at the start of every stage so definitions can be exported easily in the `stone.yml` file
 - Fixed an issue where duplicate hash files were being included in the Content Payload
   - This resulted in reducing the Content Payload size by 750MB of a glibc build with duplicate locale files
 - Finishing touches on profile guided optimization (PGO) builds - including clang's context-sensitive PGO
   - Fixed a few typos in the macros to make it all work correctly
   - Profile flags are now added to the build stages
   - Added the llvm profile merge steps after running the workload
   - Recreate a clean working directory at the start of each PGO phase

With all this now in place, the build stages of `boulder` are close to completion. But don't worry, there's plenty more
great features to come to make building packages for Serpent OS simple, flexible and performant. Next steps will be testing
out these new features to see how much they can add to the overall `stage4` performance.

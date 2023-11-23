---
title: "A Fun Place to Hang, Code and Help Out"
date: 2022-01-14T16:23:23+11:00
draft: false
Callout: "Enjoy what you do and you'll probably do more of it"
---

<!---
Why:
- A fun space people want to hang out and join
- Increase efficiency of contributors/developers

How:
- Sounds Great, Where Can I Find You?
- Lightning Fast Build System
- Smart and Simple Packaging
- Making Contributing Easy
--->

Enjoying what you do is so important that Serpent OS is about more than just robust and fast tools. By having a fun
place to hang out, we see more user engagement and an increase in contributors. This also spurs on the team to provide
the tools they need to create a flourishing Operating System.

While we enjoy hanging out with the community, packaging still needs to be done. Serpent OS combines a superfast
packaging system with smart tooling to easily create new packages for Serpent OS. With a thriving community of
contributors, they can quickly and efficiently test new changes and get them in front of users.

We go a step further to reduce frictions of contributors and developers to avoid frustrations from trying to help out
the project. The contributions of the community are pivotal to the success of many open source projects. With Serpent
OS, the line between being a user and a contributor has never been finer!

# Sounds Great, Where Can I Find You?

Check out our [Team](/team) page to find out all the places where we hang out. Or keep reading to learn how we make
contributing fast and easy.

# Lightning Fast Build System

Nobody likes to wait around for packages to build. In Serpent OS, we value your time (and ours!) so every effort is
made to make creating packages as fast and smooth as possible.

Maximising the performance of the clang compiler:
 - LTO and PGO built `clang`
 - Static `LLVM` in `clang` binary
 - Using `LLVM's` binutils variants (such as the more performant `lld` linker)

Combined these result in considerable performance benefits to `clang` and reduce what can be the longest part of
waiting for a build to finish.

{{<figure_screenshot_one image="../build_setup" caption="The parallel nature of Serpent OS helps minimize build times">}}

The unique jobs system, integrated into `boulder` and `moss`, where all tasks can run as soon as their prerequisites
are met including:
 - Fetching upstream tarballs while dependencies are calculated
 - Extracting packages and tarballs as soon as they are downloaded
 - Caching of packages means you only ever need to extract packages one time for your system and development needs

Utilizing pre-compiled headers (PCH) and unity builds:
 - Can result in significant build time reductions for packages like LibreOffice
 - `clang` enables you to instantiate templates of pre-compiled headers for even faster PCH builds

# Smart and Simple Packaging

As well as making builds lightning quick, package files need to be just as easy to create. We achieve this through:

 - Build files that are simple but powerful
   - Easy to understand the build at a glance
   - Able to quickly add extra compiler tunables to builds
   - Plug in a workload to add profile guided optimizations in your build. You don't even need to know how it works!
 - Tooling takes care of steps that can be easily automated
   - Will continue to learn tricks to cater to new workflows
 - Lets you know when you've likely made an error in packaging, so you can fix it up before someone else sees
   - Reduces the need to rework commits, which can be a barrier for some users

# Making Contributing Easy

Even the tiniest impediments to contributing are enough to turn off potential contributors. Most frictions contributors
face can be reduced, or even eliminated entirely.

Whether you simply need a few tools or enjoy the challenge, Serpent OS utilizes GitLab for packaging repositories.
There will also be community repositories where you can practice your packaging, share your experiences and eventually
start making changes upstream.

You can learn more about `boulder` [here](/boulder).

# Check Out These Related Blog Posts:

- [The Joy of Contribution](https://serpentos.com/blog/2022/01/04/the-joy-of-contribution) 4-Jan-2022

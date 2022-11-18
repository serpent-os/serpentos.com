---
title: "Packaging Automation, Next Steps"
date: 2022-06-22T17:23:14+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/packaging-automation-next-steps/Featured.webp"
---

Hot damn we've been busy lately. No, [really](https://gitlab.com/groups/serpent-os/-/activity).
The latest development cycle saw us focus exclusively on `boulder`, our build tooling. As of
today it features a proof of concept `boulder new` subcommand for the automatic generation of
packaging templates from an upstream source (i.e. tarball).

<!--more-->

Before we really start this blog post off, I'd like to thank everyone who is supporting the
project! All of the [OpenCollective](https://opencollective.com/serpent-os) contributions will make it easier for me to work full
time on Serpent OS =) Much love <3


{{<figure_screenshot_one image="packaging-automation-next-steps/Featured" caption="Look at all the buildiness">}}

### But, but build _flavours_ ...

Alright you got me there, certain projects prefer to abstract the configuration, build and
installation of packages and be provided with some kind of hint to the build system, i.e.
manually setting `autotools`, etc.

Serpent OS packaging is declarative and well structured, and relies on the use of RPM-style
"macros" for distribution integration and common tasks to ensure consistent packaging.

We prefer a self documenting approach that can be machine validated rather than depending
on introspection at the time of build. Our `stone.yml` format is very flexible and powerful,
with automatic runtime dependencies and package splitting as standard.

..Doesn't mean we can't make packaging **even easier** though.

### Build discovery

{{<giphy "bjujfYVIqpLYA">}}

Pointing boulder at an upstream source will perform a deep analysis of the sources to determine
the build system type, build dependencies, metadata, licensing etc. Right now it's just getting
ready to leave POC stage so it has a few warts, however it does have support for generating
package skeletons for the following build systems:

 - `cmake`
 - `meson`
 - `autotools`

We're adding automation for Perl and Python packaging (and Golang, Rust, etc) so we can enforce consistency,
integration and ease without being a burden on developers. This will greatly reduce the friction
of contribution - allowing anyone to package for Serpent OS.

We're also able to automatically discover build time dependencies during analysis and add those
to the skeleton `stone.yml` file. We'll enhance support for other build systems as we go, ensuring
that each new package is as close to done on creation as possible, with review and iteration left
to the developer.

### License compliance

{{<giphy "hWEPBwxwXSfUKD1Blo">}}

A common pain in the arse when packaging for *any* Linux distribution is ensuring the package
information is *compliant* in terms of licensing. As such we must know all of the licensing
information, as well as FSF and OSI compliance for our continuous integration testing.

...Finding all of that information is truly a painful process when conducted manually.
Thankfully `boulder` can perform analysis of all licensing files within the project to
greatly improve compliance and packaging.

Every license listed in a `stone.yml` file must use a valid [SPDX](https://spdx.dev/) identifier,
and be accurate. boulder now scans all license files, looking for matches with both SPDX IDs
as well as fuzzy-matching the text of input licenses to make a best-guess at the license ID.

This has so far been highly accurate and correctly identifies many hundreds of licenses,
ensuring a compliant packaging process with less pain for the developers. Over time we'll
optimise and improve this process to ensure compliance *for* our developers rather than
blocking them.

As of today we support the [REUSE](https://reuse.software/) specification for expressing software licenses too!

## Next on the list

The next steps are honest-to-goodness exciting for us. Or should I say.. exiting?

### bill

Work formally begins now on Bootstrap Bill (Turner). Whilst we did successfully bootstrap Serpent OS
and construct the `Protosnek` repository, the process for that is **not** reproducible as `boulder`
has gone through massive changes in this time.

The new [project](https://gitlab.com/serpent-os/core/bill) will leverage `boulder` and a newly
designed bootstrap process to eliminate all host contamination and bootstrap Serpent OS from
`stone.yml` files, emitting an _immutable_ bootstrap repository.

Layering support will land in `moss` and `boulder` to begin the infrastructure projects.

### Build Submission ("Let's Roll")

The aim is to complete `bill` in a very short time so we can bring some initial infrastructure
online to facilitate the automatic build of submitted build jobs. We'll use this process
to create our live repository, replacing the initial bootstrap repository from bill.

At this point all of the tooling we have will come together to allow us all to very
quickly iterate on packaging, polish up `moss` and race towards installed systems with
online updates.

{{<giphy "ZCZRQyuQNyzyU">}}


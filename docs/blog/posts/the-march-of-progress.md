---
title: "The March Of Progress"
date: 2024-03-31T23:56:54+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
---

Despite a brief excursion out of the country for a first-in-a-lifetime holiday, I'm happily back at the desk to bring you up to date with the
latest goings in Serpent OS. TLDR: Loads of awesome, baremetal is enabled, ISO cycle in next couple of weeks.

![GNOME on Serpent OS](../../static/img/blog/the-march-of-progress/Gnome.webp)

<!-- more -->

## Tooling Improvements

OK, we all know you want to know about the baremetal stuff, but c'mon, check out this changeset!

### Boulder

We're officially at a point where the Rust boulder implementation has become our "blessed" build tool. This is actually a crate within the `moss`
repository, allowing the two tools to share huge chunks of code. Our focus over the past few weeks has been to ensure we can drop the tool into
our existing build network and "just work", while making it significantly faster.

One of the most important high level changes is *performance*, in some cases virtually 50% faster packaging times. Our package payloads are now
compressed using multi-threaded zstd compression, and a bunch of internal components were reworked to use faster code paths leading to a significant
speed up in the raw generation of each `.stone` package.

!!! warning "Legacy boulder tool has been retired"

    As of March 31st, 2024, the legacy D implementation of `boulder` is no longer supported. The runtime component, `mason`, has been removed from the
    volatile repository. Our new tool is written in Rust and contains the `moss` code, enabling a self-contained all-in-one approach to buildroot  management.

    It relies on clone-based user namespaces, so is fully "rootless". Please migrate immediately to the new Rust based tool. Not only is it more advanced,
    it is significantly faster at generating the raw `.stone` packages.

![Comparison](../../static/img/blog/the-march-of-progress/Featured.webp)

Other, quite awesome changes:

 - Fix manifest encoding for `0` nul byte, interop with build systems
 - Explicit `--update` flag to refresh the repositories prior to build
 - Defaults to multithread zstd compression
 - Slick timing reports
 - Base-enabling landed for "meta" packages (contain no files or content)
 - Added `BuildRelease` control via tooling for automated package rebuilds

### Moss

Moss also got some love these past few weeks, including a full migration over to [diesel.rs](https://diesel.rs/). Combined with a limiting of `async`
to largely network bound operations, and some clever performance optimisations under the hood, moss is now faster than ever. In fact, we're able to
generate desktop ISOs in under 20 seconds, and install the full GNOME desktop to a `virtiofs` VM in almost no time.

 - Dropped some unnecessary dependencies
 - Significant code cleanups
 - Further refined our system + transaction triggers to fully respect dependency ordering
 - Augmented state management with new functionality to activate/rollback to a specific transaction by ID using offline store.
 - Various optimisations:
   - Drop expensive `Path` usage in `vfs` crate
   - Optimise queries in our transaction management to speed up `DAG` initialisation and filesystem blit
   - And more to be covered in a future blog post

## Hardware/Desktop Enablings.

Rather than extensively widen our repository at this point we've opted for further low-level enabling of components required for the developer
experience desktop. This includes Network Manager, the desktop kernel package, Vulkan + mesa integration, etc.

![Gnome Software](../../static/img/blog/the-march-of-progress/GnomeSW.webp)

As well as enabling core applications and features such as GNOME Software and Flatpak, we've also enabled preliminary usage on baremetal booting
hardware. Note, this isn't yet installable but we do plan to offer early access installable images to our [sponsors](https://github.com/sponsors/ikeycode)!

Also worth noting.. we've begun to package the Cosmic Epoch desktop from the cool guys over at [System76](https://system76.com/). We're highly interested
in this project and plan to track progress closely, offering it within Serpent OS as a fully featured development focused desktop experience.

## The Agenda

This post was finished moments before the March deadline, so needless to say we've been super busy! Thankfully a lot of pivotal pieces have landed now and
we can focus on some big ticket items. Our primary concern is to ship one last "pre-alpha" image for the public, and a test installable pre-alpha ISO for
our sponsors to help gain early feedback. The hope is this will help fund a widening of our infrastructure to support more concurrent repository users and
our own `debuginfod` compatible extensions to our repository.

The April (and beyond) agenda:

 - Finish pre-alpha stage with some shiny ISOs!
 - Enter alpha by adding versioned repository support to moss for an "upgrade forever" guarantee
 - Enhance our ABI tracking story to vastly simplify huge rebuild queues and automation
 - Expand our native hardware support
 - Add some missing basic triggers such as Fedora-compatible SSL certificate management
 - Begin work on the all-important **boot management** in moss! (not boot LOADER, this will be `systemd-boot`)
 - Add battery testing of our tooling to our CI pipelines to protect users
 - Ensure all of our code is fully documented
 - Greatly improve our onboarding and documentation for packaging and usage of Serpent OS, focusing on `stone.yaml` in depth
 - Get core team running Serpent OS daily. WiFi and GPU support are in place already.
 - Build an amazing developer experience

On behalf of the Serpent OS team, I look forward to sharing some amazing updates with you towards the end of April! Keep your eyes peeled for the ISO drops
in the coming weeks.
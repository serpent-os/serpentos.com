---
title: "Solidifying the direction"
date: 2023-06-02T20:08:50+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/solidifying-direction/Featured.webp"
---

It's been quite a while since our last post, and a great many questions emerged as a result of our announced cooperation with the Solus project.
This post will clarify a few points, including our technical approach to solving problems as well as the relationship between the two projects
going forwards.

<!--more-->

## A Developer Focused Upstream

Serpent OS and Solus will largely share source and binary repositories, with both teams collaborating on the majority of packages. Our primary
focus will be the delivery of a developer experience ISO, provisioning tooling and containers. Solus will continue to focus on the quality user
experience they have always provided, building Solus 5 on a solid technical foundation. Where differentiation from the upstream packages is required,
Solus will ship these separately in an overlay repository.

In essence, we will share a single core, and enable both teams to deliver on a larger vision. The repositories within the [snekpit](https://github.com/snekpit) organisation will be used to flesh out future Serpent + Solus packages. We do not anticipate this being close to complete for some time,
but will focus more heavily on package *conversion* after our tooling is in the right place.

Note that we plan reliance on `user repositories`, `flatpak` and such for many third party packages that have traditionally been provided by the
Solus `3rd-party` mechanism.

## Technical Stack

The last month has also involved a heavy review of our stack to discover potential shortcomings. For some contributors, there was a strong desire to use Rust. I'd like to iterate some points as to why we'll continue using [D Lang](https://dlang.org).

 - Memory safety always existed in a primitive form via the GC, full Ownership / Borrowing is being implemented by virtue of [DIP1000](https://dlang.org/blog/2022/06/21/dip1000-memory-safety-in-a-modern-system-programming-language-pt-1/) & [DIP1021](https://dlang.org/spec/ob.html).
 - For the majority of use cases, a GC isn't a hindrance, rather an aid to developers.
 - Where performance matters, D delivers. Custom allocation strategies are baked in via `std.experimental.allocator`
 - Zero-cost abstractions live at the heart of the language: Ranges are an integral concept, not a `trait`.
 - The D Language Foundation is actively engaging with the community and prioritising a [new era](https://forum.dlang.org/thread/avvmlvjmvdniwwxemcqu@forum.dlang.org) for D Lang.
 - We're amazingly productive when using D lang.

 This is not a "Rust vs D" flamebait post - some people are extraordinarily gifted with Rust. I'm not one of those people, and I firmly believe that
 D is highly underrated and misunderstood. In recent times D has been going from strength to strength, demonstrating itself as a capable systems programming language and adapting to developer requirements.  We'd like to be a part of that future.

## A new development cycle

Before we kick off this new cycle, let's establish a few facts.

 - We've had to review our approach to Serpent to ensure both Serpent and Solus co-exist in a fashion that is beneficial to all involved.
 - We've been doing D wrong. For years.

It's worth pointing out I was a C developer for many years, and formed many (bad) habits and conceptions as a result of that. This is more than
evident in the current tooling, and I'm dissatisfied. As the team and myself have grown in our proficiency with the language, it has become increasingly clear we've been going about things the wrong (C) way!

We're now entering our second major revision of the tooling, and will implement this using `@safe` idiomatic D lang code for a more robust tooling implementation.

 - Fewer external C dependencies
 - Asynchronous I/O model
 - Focus on proper exception handling model
 - Eliminate unnecessary runtime copies (excessive array construction rather than ranges)
 - Boot **management** support (i.e. `systemd-boot`, `grub2`, etc)
 - System trigger support
 - Offline rollback implementation
 - A `moss-daemon` binary for integration with software centers
 - Heavier use of idiomatic D code rather than OOP-style APIs

We look forward to updating you soon on the latest changes, including refreshed ISOs, packages, tooling *and* unbreaking the docker image!
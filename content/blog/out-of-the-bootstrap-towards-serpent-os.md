---
title: "Out of the Bootstrap - Towards Serpent OS"
date: 2021-12-02T18:07:12+11:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/out-of-the-bootstrap-towards-serpent-os/Featured.png"
---

The initial `stone` packages that will seed the first Serpent OS repo have now been finalized! This means that work
towards setting up the infrastructure for live package updates begins now. We plan on taking time to streamline the
processes with a focus of fixing issues at the source. In this way we can make packaging fast and efficient so we can
spend time working on features rather than package updates.

<!--more-->

#### The End of Bootstrap

Bootstrapping a distribution involves building a new toolchain and many packages needed to support it. For us bootstrap
was getting us to the point where we have built `stone` packages that we can use to start an initial repository with
full working dependencies. This has been enabled by integrating dependencies into `moss`, creating the first repo index.
Of note is that it is already enabled for 32bit support, so we have you covered there. While this is the end of
bootstrap, the fun has only just begun!

{{<figure_screenshot_one image="out-of-the-bootstrap-towards-serpent-os/Featured" caption="The first install from the bootstrap">}}

#### Where to Next?

The next goal is to make Serpent OS self-hosting, where we can build packages in a container and update the repo index
with the newly built packages. It is essentially a live repository accessible from the internet. There's still plenty of
improvements to be made with the tooling, but will soon enable more users to participate in bringing Serpent OS into
fruition.

#### Becoming More Inclusive

While there's a strong focus in Serpent OS on performance, the decision has been made to lower the initial requirements
for users. Despite AVX2 being an older technology, there are still computers sold today that don't support it. Because
of this (and already having interested users who don't have newer machines), the baseline requirement for Serpent OS
will be `x86_64-v2`, which only requires SSE4.2.

It was always the plan to add support for these machines, just later down the track. In reality, this makes a lot more
sense, as there will be many cases where building 2 versions of a package provides little value. This is where a package
takes a long time to build and doesn't result in a notable performance improvement. We will always need the `x86_64-v2`
version of a package to be compatible with the older machines. With this approach we can reduce the build server
requirements without a noticeable impact to users as only a few packages you use will be without extra optimizations
(and probably don't benefit from them anyway).

I want to make it clear that this will be temporary, with impactful `x86_64-v3+` packages rolling out as soon as
possible. This change paves the way to integrate our technology stack taking care of your system for you and increases
its priority. Users meeting the requirements of the `x86_64-v3+` instruction set (this includes additional instructions
beyond `x86_64-v3`) will automatically start installing these faster packages as they become available. Our
`subscriptions` model will seamlessly take care of everything for you behind the scenes so you don't need to read a
wiki or forum to learn how to get these faster packages. We can utilize the same approach in future for our `ARM` stack,
offering more optimized packages where it provides the most benefit.

Note that from the bootstrap, most packages built in under 15s and only three took longer than 2 minutes.

#### Trying Out Some Tweaks From the Get Go

While the project is young is a great time to test out new technologies. The use of `clang` and `lld` open up new
possibilities to reduce file sizes, shorten load times and decrease memory usage. Some of these choices may have
impacts on compatibility, so testing them out will be the best way to grasp that. Making sure that you can run apps like
Steam is vital to the experience, so whatever happens we will make sure it works. The good news is that due to the
unique architecture of Serpent OS, we can push updates that break compatibility with just a reboot, so if we ever feel
the need to change the `libc`, we can make the change without you having to reinstall! More importantly, we can test
major stack updates by rebooting into a staged update and go straight back to the old system, regardless of your file
system.

#### Speed Packaging!

In the early days of the repository, tooling to make creating new packages as simple as possible is vital for
efficiency. Spending some time automating as much of the process as possible will take weeks off bringing up Serpent OS.
By making packaging as easy as possible will also help users when creating their own packages. While it would be faster
to work around issues, the build tooling upgrades will benefit everyone.

The other way we'll be speeding up the process is by holding back some of the tuning options by default. `LTO` for
instance can result in much longer build times so will not initially be the default. The same is true for debug
packages, where it slows down progress without any tangible benefit.

#### Things Are Happening!

We hope you are as excited as we are!

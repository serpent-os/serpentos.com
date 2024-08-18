---
hide:
    - navigation
    - footer
title: Home
---

# An operating system should look after itself

We're creating Serpent OS, an independent Linux distribution built from the ground up to look after itself. Relying heavily
on our Rust-based tooling, the distribution has a number of awesome features:

 - Rebootless atomic updates - no more interruptions
 - Offline rollback to older install (filesystem agnostic)
 - Remains fully composable using **packages**, not container registries.
 - Automatically managed `ESP`, `XBOOTLDR` partitions and boot entries
 - Doesn't rely on AB partitions, ostree or overlayfs, thus not suffering the same limitations and performance issues.
 - Stateless: Just nuke `/etc` & `/var` to factory reset. Packages should Just Work when installed.
 - Preference for modern technology: We default to the [LLVM](https://llvm.org/) toolchain, [sudo-rs](https://github.com/trifectatechfoundation/sudo-rs), [Wayland](https://wayland.freedesktop.org/), [rustls](https://github.com/rustls/rustls), etc.
 - Built by jaded experts: With decades of distribution engineering experience under our belts, we got tired of tweaking and just want the damn thing to work when it's installed.
 - and much more

[:fontawesome-solid-download: Try prealpha today](/download){ .md-button } [:fontawesome-solid-gift: Sponsor us!](https://github.com/sponsors/ikeycode){ .md-button }

## What can I do with Serpent OS?

Right now our **primary target** is the developer audience. Truthfully we're very quickly improving the tooling to better
serve the distribution, which in turn will enable more workflows and users. We ship with both the GNOME Desktop and the COSMIC Desktop


![In action](static/Landing.webp)


## What is Serpent OS?

Serpent OS is an independent Linux-based operating system built upon a variety of open source technologies. Most importantly,
it is an attempt to provide a **sane** installation that cannot be "broken" by updates. It does this through a variety of
recovery mechanisms, including on-disk offline rollbacks and system deduplication.

We acknowledge that updates can go wrong, despite striving to avoid breakage with our advanced tooling and processes. This
is why we designed with recovery in mind - reboot to the last transaction, be confident with package triggers that run in
isolated containers.

## Meet the tools

We said we care deeply - and this is made a reality through our tooling. Whether it's package builds, orchestration of updates,
or the package manager itself, each component is crafted with care and extensive experience and is fully open source.

### :rocket: moss - blazing fast package management

Whether you're using Linux for home or work, we've got you covered. Don't wait around for old package managers
or bundles; turbocharge your installations and containers with [moss](https://github.com/serpent-os/moss) and Serpent OS.

#### :atom: Atomic transactions

Every package management operation creates an entirely self contained transaction, offering rollbacks to earlier points in
time as well as ensuring new updates are safe to apply. Unlike other "A/B" transaction systems, `moss` can make the new
system root available immediately.

#### :zap: Ridiculously fast

We leverage the fastest technologies and techniques to provide *ridiculously* fast package management.

 - [xxHash](https://xxhash.com) for content addressable hashes. Zip!
 - [Zstandard](https://github.com/facebook/zstd) for package compression, kernel modules, firmware, etc.
 - Upcoming: [BLAKE3](https://github.com/BLAKE3-team/BLAKE3) for verification!

#### :lock: Safer

 - :crab: Core tooling is written in Rust, with support tooling in the process of being ported. Memory safe with extremely fast execution.
 - :warning: Self-contained builds of essential system tools - moss can recover your system if you accidentally remove glibc!

### :hammer: boulder: A better way to package

We've been building tools to build systems for a long time and came to an obvious conclusion: Packaging is, by and large,
a set of *policies* applied to the final build artifacts of compliant source packages.

#### :superhero: Superpowered packaging

Our simple yet powerful `stone.yml` format makes it a breeze to create packages for Serpent OS. Whip them through [boulder](https://github.com/serpent-os/moss), our
container-based build tool, and have binary packages in no time.

No steep learning curve, just some YAML and an extremely intelligent package build system capable of automatically splitting packages into
the correct subpackages and recording their dependencies. Heck, we can even generate a recipe from an upstream release! :astonished:

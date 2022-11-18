---
title: "Who Knew Building Packages Could be so Easy?"
date: 2022-01-06T17:18:34+11:00
draft: false
Callout: "boulder makes creating packages fast and efficient, taking out all the leg work"
---

<!---
Why:
- Building packages takes too long
- Packaging should be as easy as possible, without needing OS specific knowledge

What:
- Really Fast to Set Up Builds (awesome package caching)
- A New Parallel Model (parallel downloads with caching while downloading)
- Post Build Analysis Also in Parallel
- Optimized Toolchain to Make Builds Faster (not boulder but key, potentially link back to fast page)
- Simple Yet Flexible Build Format (basic `stone.yml`)
- A Keen Eye On Performance (output optimized packages - toolchain switching, v2 and v3+, PGO, compiler flags)
- Getting the Most Out of Performance Options (integrating benchmarks)
- Automate As Much As Possible (auto dependency detection all over)
--->

The goal of `boulder` is to make creating packages so easy that anyone could do it! For veterans it means that time can
be spent on the more important parts of the distro. As `boulder` and `moss` share the same codebase, the advantages
built into `moss` also benefit `boulder`! There's very little to learn before getting started!

Reducing the time spent packaging saves everyone time, over and over again. This is why the process is highly tuned to
minimize the time at each step. Packagers build a lot of packages and users can take advantage of source builds without
the long wait time. Every second counts and we save a lot of them!

# Really Fast to Set Up Builds

A real time sink of shorter builds is the time it takes to create the build environment and extract the needed
dependencies. We've seen many variations of build environments from setting up a root image to build from in a minimal
chroot or container to full VM builds. For a package like `nano` the build stage is only a couple of seconds, so taking
up to a minute to set up the build would be unacceptable!

One of the fundamental differences with `boulder` and `moss` is sharing of installed packages, so a new package only
needs to be extracted and cached one time and can be reused for multiple system roots and as many builds as needed. If
you've used the package before, you won't have to extract it again. Waiting for packages to extract at the start of a
build is now a thing of the past!

# A New Parallel Model

There's been many good improvements to speed up build setups such as parallel downloads and using `zstd` for faster
decompression of packages. But underneath you find the process is still sequential, you download the files in parallel,
but you have to wait till all files are downloaded before starting to install them. With `boulder` (and `moss`),
packages will be queued for extraction (caching) as soon as they are downloaded! So by the time you finish downloading
the last file, the other files are already installed so you can get started.

# Post Build Analysis Also in Parallel

Using the same parallel model we are able to make huge reductions to the time taken in the post build stages as well.
At the end of the build, files are scanned so they can be processed by their type as well creating hashes for each file.
As an example, for an `ELF` file we need to separate the debug information and `strip` the final binary to minimize
its size. There's a lot of overhead involved (especially when calling out to external programs like `strip`), so takes
a long time when processing sequentially. The good news is that with `boulder` you won't have to wait and really cuts
down on waiting after the build is complete.

# Optimized Toolchain to Make Builds Faster

While this isn't technically `boulder`, a turbo charged compiler compounds the gains from the parallel pre and post
builds. We go to great lengths to build `clang` with PGO+LTO (and soon with `llvm-bolt`). With tackling each part of the
process we make packaging easy and less time consuming.

# Simple Yet Flexible Build Format

The `stone.yml` packaging format is quite simple, yet flexible when required. Using easy to understand `YAML`
formatting, a `stone.yml` will be compact for the majority of cases. Here's a simple example of the `nano` build file:

```yaml
name        : nano
version     : 5.8
release     : 1
summary     : GNU Text Editor
license     : GPL-3.0-or-later
homepage    : https://www.nano-editor.org/
description : |
    The GNU Text Editor
upstreams   :
    - https://www.nano-editor.org/dist/v5/nano-5.8.tar.xz : e43b63db2f78336e2aa123e8d015dbabc1720a15361714bfd4b1bb4e5e87768c
setup       : |
    %configure
build       : |
    %make
install     : |
    %make_install
```

The rules of how packages are split into separate `-devel` packages are taken care of for you. This helps new packagers a
lot as there's no need to learn all these packaging rules and reduces the number of mistakes that they make. In rare
circumstances you may need to override one of these rules and `boulder` makes that easy too!

Details of the build are output as `manifest` files, which track the files contained in each package, the dependencies
and the `ABI`. Being tracked in `git` it's easy to see the result of any changes to the build.

# A Keen Eye On Performance

With the importance of performance in Serpent OS, it is essential that `boulder` is able to output fast and small
packages. One compiler does not always provide the fastest result so `boulder` provides an option to switch between the
`LLVM` and `GNU` toolchains (`LLVM` being the default).

Compatibility and performance are not mutually exclusive. `boulder` is designed from the outset with a
multi-architecture approach. This means we can build the package multiple times for old and newer CPU architectures. A
baseline of `x86-64-v2` provides compatibility for processors released all the way back in 2010, while the more
optimized `x86-64-v3+` builds provide greater performance for more recent CPUs that include the advanced capabilities.

One part of the build process that is easy to automate is building with profile guided optimizations (PGO). This involves
running a representative workload from a build with instrumentation to learn how it runs and what paths it typically
takes. With this information the compiler can learn and build a more efficient program and reduce cache pressure. It
does increase the build time quite a lot, but is well worth it in many circumstances. `boulder` also includes support
for two stage context sensitive PGO with `clang`.

Compiler flags are another way to squeeze out the last bit of performance from package builds. The performance gain in
`python` from adding `--no-semantic-interposition` was well into double figures, which highlights the benefits from
adding performance flags where appropriate. `boulder` exposes a range of tunables to add (or remove from the defaults)
on a per build basis to help facilitate performance testing. But how do you know which options improve performance?

# Getting the Most Out of Performance Options

Benchmarking can be a time consuming process, but it doesn't have to be. By integrating benchmarks with the packaging
files, they are easily accessible and allows all users to test the performance of packages. It also makes it extremely easy to
automate tests within `boulder` to compare multiple configurations and whether any tuning flags have a positive
performance. Benchmarking is more than a one-off process, and regular testing allows us to identify regressions early to
make data driven choices.

# Automate As Much As Possible

With differences between distros, manually adding package names can be a real hassle. `boulder` is designed to detect
as many build dependencies as possible so that you don't have to! It also reads the build file to determine the build
tooling required to complete the build. So if you use the `%cmake` we already know you'll want the `cmake` package
installed, so you don't need to muck around ensuring every little dependency is included, or having to restart the build
because you forgot it. This is also true for dependencies of created packages, where only required dependencies are
added. Therefore if a package removes a dependency (which you may not even be aware of), you don't have to remember to
remove it.

# Check Out These Related Blog Posts:

- [Unpacking the Build Process: Part 1](/blog/2021/08/25/unpacking-the-build-process-part-1) 25-Aug-2021
- [Unpacking the Build Process: Part 2](/blog/2021/09/20/unpacking-the-build-process-part-2) 20-Sep-2021

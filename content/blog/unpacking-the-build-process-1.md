---
title: "Unpacking the Build Process: Part 1"
date: 2021-08-25T19:04:12+10:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/unpacking-the-build-process-1/Featured.png"
---

While the build process (or packaging as it's commonly referred to) is largely hidden to most users, it forms a
fundamental and important aspect to the efficiency of development. In Serpent OS this efficiency also extends to
users via source based builds for packages you may want to try/use that aren't available as binaries upstream.

<!--more-->

The build process can be thought of in three distinct parts, setting up the build environment, compiling the source
and post build analysis plus package creation. Please note that this process hasn't been finalized in Serpent OS so
we will be making further changes to the process where possible.

#### Setting up the Build Environment

Some key parts to setting up the build environment:

- Downloading packages needed as dependencies for the build
- Downloading upstream source files used in the build
- Fetching and analyzing the latest repository index
- Creating a reproducible environment for the build (chroot, container or VM for example)
- Extracting and installing packages into the environment
- Extracting tarballs for the build (this is frequently incorporated as part of the build process instead)

While the focus of early optimization work has been on build time performance, there's more overhead to creating
packages time than simply compiling code. Now the compiler is in a good place, we can explore the rest of the
build process.

#### Packaging is More than just Compile Time

There's been plenty of progress in speeding up the creation of the build environment such as parallel downloads to
reduce connection overhead and using `zstd` for the fast decompression of packages. But there's more that we can
do to provide an optimal experience to our packagers.

Some parts of the process are challenging to optimize as while you can download multiple files at once to ensure
maximum throughput, you are still ultimately limited by your internet speed. When packaging regularly (or building
a single package multiple times), downloaded files are cached so become a one off cost. One part we have taken
particular interest in speeding up is extracting and installing packages into the environment.

{{<figure_screenshot_one image="unpacking-the-build-process-1/Featured" caption="Eight seconds (for a small number of dependencies) that don't need to be endlessly repeated">}}

#### The Dynamic Duo: boulder and moss

Installing packages to a clean environment can be the most time consuming part of setting up the build (excluding
fetching files which is highly variable). Serpent OS has a massive advantage with the design of `moss` where
packages are cached (extracted on disk) and ready to be used by multiple roots, including the creation of clean
build environments for `boulder`. Having experienced a few build systems in action, setting up the root could take
quite some time with a large number of dependencies (even getting over a minute). `moss` avoids the cost of extracting
packages entirely every build by utilizing its cache!

There are also secondary benefits to how `moss` handles packages via its caches where disk writes are reduced by only
needing to extract packages a single time. But hang on, won't you be using `tmpfs` for builds? Of course we will have
RAM builds as an option and there are benefits there too! When extracting packages to the RAM disk, it consumes memory
which can add up to more than a GB before the build even begins. `moss` allows for us to start with an empty `tmpfs` so
we can perform larger builds before exhausting the memory available on our system.

Another great benefit is due to the atomic nature of `moss`. This means that we can add packages to be cached as
soon as they're fetched while waiting for the remaining files to finish downloading (both for `boulder` and system
updates). Scheduling jobs becomes much more efficient and we can have the build environment available in moments after
the last file is downloaded!

`moss` allows us to eliminate one of the bigger time sinks in setting up builds, enabling developers and
contributors alike to be more efficient in getting work done for Serpent OS. With greater efficiency it may become
possible to provide a second architecture for older machines (if the demand arises).

#### Part 1?

Yes, there's plenty more to discuss so there will be more follow up posts showing the cool features Serpent OS is doing
to both reduce the time taken to build packages and in making packages easier to create so stay tuned!

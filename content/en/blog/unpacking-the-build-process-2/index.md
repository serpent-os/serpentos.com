---
title: "Unpacking the Build Process: Part 2"
date: 2021-09-20T16:04:12+10:00
draft: false
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/unpacking-the-build-process-2/Featured.webp"
---

Part 2 looks at the core of the build process, turning the source into compiled code. In Serpent OS this is handled by
our build tool `boulder`. It is usually the part of the build that takes the longest, so where speed ups have the most
impact. How long it takes is largely down to the performance of your compiler and what compile flags you are building
with.

<!--more-->

This post follows on from [Part 1](/blog/2021/08/25/unpacking-the-build-process-part-1).

# Turning Source into Compiled Code

The steps for compiling code are generally quite straight-forward:
- Setting up the build (cmake, configure, meson)
- Compiling the source (in parallel threads)
- Installing the build into a package directory

This will build software compiled against packages installed on your system. It's a bit more complicated when packaging
as we first set up an environment to compile in (Part 1). But even then you have many choices to make and each can have
an impact on how long it takes to compile the code. Do you build with Link Time Optimizations (LTO) or Profile Guided
Optimizations (PGO), do you build the package for performance or for the smallest size? Then there's packages that
benefit considerably from individual tuning flags (like `-fno-semantic-interposition` with `python`). With so many
possibilities, `boulder` helps us utilize them through convenient configuration options.

# What Makes boulder so Special?

As I do a lot of packaging and performance tuning, `boulder` is where I spend most of my time. Here are some key
features that `boulder` brings to make my life easier.

 - Ultimate control over build C/CXX/LDFLAGS via the tuning key
 - Integrated 2 stage context sensitive PGO builds with a single line workload
 - Able to switch between `gnu` and `llvm` toolchains easily
 - Rules based package creation
 - Control the extraction locations for multiple upstream tarballs

`boulder` will also be used to generate and amend our `stone.yml` files to take care of as much as possible
automatically. This is only the beginning for `boulder` as it will continue to be expanded to learn new tricks to make
packaging more automated and able to bring more information to help packagers know when they can improve their
`stone.yml`, or alert them that something might be missing.

Serpent OS is focused on the performance of produced packages, even if that means that builds will take longer to
complete. This is why we have put in significant efforts to speed up the compiler and setup tools in order to offset and
minimize the time needed to enable greater performance.

# Why do You Care so Much About Setup Time?

My initial testing focused on the performance of `clang` as well as the time taken to run `cmake` and `configure`. This
lays the foundation for all future work in expanding the Serpent OS package archives at a much faster pace. On the
surface, running `cmake` can be a small part of the overall build. However, it is important in that it utilizes a single
thread, so is not sped up by adding more CPU cores like the compile time is. With a more compile heavy build, our
highly tuned compiler can build the source in around 75s. So tuning the setup step to run in 5s rather than 10s actually
reduces the overall build time by an additional 6%!

There are many smaller packages where the setup time is an even higher proportion of the overall build and becomes more
relevant as you increase the numbers of threads on the builder. For example, when building `nano` on the host, the
configure step takes 13.5s, while the build itself takes only 2.3s, so there's significant gains to be had from speeding
up the setup stage of a build (which we will absolutely be taking advantage of!).

# A Closer Look at the clang Compiler's Performance

A first cut of the compiler results were shared earlier in [Initial Performance Testing](../blog/2021/08/02/initial-performance-testing),
and given the importance to overall build time, I've been taking a closer look. In the post I said that `"At stages
where I would have expected to be ahead already, the compile performance was only equal"` and now I have identified the
discrepancy.

I've tested multiple configurations for the `clang` compiler and noticed that changing the default standard C++ library
makes a difference to the time of this particular build. The difference in the two runs is compiling `llvm-ar` with the
LLVM libraries of `compiler-rt/libc++/libunwind` or the GNU libraries of `libgcc/libstdc++`. And just to be clear, this
is increasing the time of compiling `llvm-ar` with `libc++` vs `libstdc++` and not to do with the performance of either
library. The `clang` compiler itself is built with `libc++` in both cases as it produces a faster compiler.

{{<figure_screenshot_one image="unpacking-the-build-process-2/Featured" caption="">}}

| Test using clang      | Serpent LLVM libs | Serpent GNU libs |  Host        |
|-----------------------|-------------------|------------------|--------------|
| `cmake` LLVM          | 5.89s             | 5.67s            |  10.58s      |
| Compile -j4 `llvm-ar` | 126.16s           | 112.51s          |  155.32s     |
| `configure` gettext   | 36.64s            | 36.98s           |  63.55s      |

The host now takes `38% longer` than the Serpent OS clang when building with the same GNU libraries and is much more in
line with my expectations. Next steps will be getting `bolt` and `perf` integrated into Serpent OS to see if we can
shave even more time off the build.

What remains unclear is whether this difference is due to something specifically in the `LLVM` build or whether it would
translate to other C++ packages. I haven't noticed a 10% increase in build time when performing the full compiler
build with `libc++` vs `libstdc++`.

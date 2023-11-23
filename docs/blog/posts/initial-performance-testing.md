---
title: "Initial Performance Testing"
date: 2021-08-02T11:28:24+10:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
---

With further progress on `boulder`, we can now build native stone packages with some easy tweaks such as profile
guided optimizations (PGO) and link time optimizations (LTO). That means we can take a first look at what the
performance of the first cut of Serpent OS shows for the future. The tests have been conducted using
[`benchmarking-tools`](https://github.com/sunnyflunk/benchmarking-tools) with Serpent OS measured in a `chroot` on
the same host with the same kernel and config.

<!--more-->

One of the key focuses for early in the project is on reducing build time. Every feature can either add or subtract
from the time it takes to produce a package. With a source/binary hybrid model, users will greatly benefit from the
faster builds as well. In terms of what I've targeted in these tests is the performance of `clang` and testing some
compiler flag options on `cmake`.

# Clang Shows its Promise

`clang` has always been a compiler with a big future. The performance credentials have also been improving each release
and are now starting to see it perform strongly against its `GNU` counterpart. It is common to hear that `clang` is slow
and produces less optimized code. I will admit that most distros provide a slow build of `clang`, but that will not be
the case in Serpent OS.

It is important to note that in this comparison the Host distro has pulled in some patches from `LLVM-13` that greatly
improve the performance of `clang`. Prior to this, their tests actually took `50% longer` for `cmake` and `configure`
but only `10% longer` for compiling. `boulder` does not yet support patching in builds so the packages are completely
vanilla.

| Test using clang      | Serpent      | Host        | Difference |
|-----------------------|--------------|-------------|------------|
| `cmake` LLVM          | 5.89s        | 10.58s      | 79.7%      |
| Compile -j4 `llvm-ar` | 126.16s      | 155.32s     | 23.1%      |
| `configure` gettext   | 36.64s       | 63.55s      | 73.4%      |

Based on the results during testing, the performance of `clang` in Serpent OS still has room to improve and was just a
quick tuning pass. At stages where I would have expected to be ahead already, the compile performance was only equal
(but `cmake` and `configure` were still well ahead).

# GCC Matters Too!

While `clang` is the default compiler in Serpent OS, there may be instances where the performance is not quite where it
could be. It is common to see software have more optimized code paths where they are not tested with `clang` upstream. As
an example, here's a couple of patches in flac ([1](https://github.com/xiph/flac/commit/67ea8badadd3e63b8e8af5fe837d075104569330),
[2](https://github.com/xiph/flac/commit/d4a1b345dd16591ff6f17c67ee519afebe2f9792)) that demonstrate this being improved.
Using `benchmarking-tools`, it is easy to see where `gcc` and `clang` builds are running different functions via `perf`
results.

In circumstances where the slowdown is due to hitting poor optimization paths in `clang`, we always have the option to
build packages using `gcc`, where the `GNU` toolchain is essential for building `glibc`. Therefore having a solid `GNU`
toolchain is important but small compile time improvements won't be noticed by users or developers as much.

| Test using gcc      | Serpent      | Host        | Difference |
|---------------------|--------------|-------------|------------|
| `cmake` LLVM        | 7.00s        | 7.95s       | 13.6%      |
| Compile `llvm-ar`   | 168.11s      | 199.07s     | 18.4%      |
| `configure` gettext | 45.45s       | 51.93s      | 14.3%      |

# An OS is More Than Just a Compiler

While the current bootstrap exists only as a starting point for building the rest of Serpent OS, there are some other
packages we can easily test and compare. Here's a summary of those results.

| Test                              | Serpent      | Host        | Difference |
|-----------------------------------|--------------|-------------|------------|
| Pybench                           | 1199.67ms    | 1024.33ms   | -14.6%     |
| `xz` Compress Kernel (-3 -T1)     | 42.67s       | 46.57s      | 9.1%       |
| `xz` Compress Kernel (-9 -T4)     | 71.25s       | 76.12s      | 6.8%       |
| `xz` Decompress Kernel            | 8.03s        | 8.18s       | 1.9%       |
| `zlib` Compress Kernel            | 12.60s       | 13.17s      | 4.5%       |
| `zlib` Decompress Kernel          | 5.14s        | 5.21s       | 1.4%       |
| `zstd` Compress Kernel (-8 -T1)   | 5.77s        | 7.06s       | 22.3%      |
| `zstd` Compress Kernel (-19 -T4)  | 51.87s       | 66.52s      | 28.3%      |
| `zstd` Decompress Kernel          | 2.90s        | 3.08s       | 6.3%       |

# State of the Bootstrap

From my experiences with testing the bootstrap, it is clear there's some cobwebs in there that require some more iterations
of the toolchain.
There also seems to be some slowdowns in not including all the dependencies of some packages. Once more packages are included,
naturally all the testing will be redone and help influence the default compiler flags of the project.

It's not yet clear the experience of using `libc++` vs `libstdc++` with the `clang` compiler. Once the cobwebs are out and
Serpent OS further developed, the impact (if any) should become more obvious. There are also some parts not yet included in
`boulder` such as stripping files, LTO and other flags by default that will speed up loading libraries. At this stage this is
deliberate until integrating outputs from builds (such as symbol information).

But this provides an excellent platform to build out the rest of the OS. The raw speed of the `clang` compiler will make
iterating and expanding the package set a real joy!

# Hang On, What's Going on With Python?

Very astute of you to notice! `python` in its current state is an absolute minimal build of `python` in order to run `meson`.
However, I did an `analyze` run in `benchmarking-tools` where it became obvious that they were doing completely different
things.

![Apples and oranges comparison](../../static/img/blog/initial-performance-testing/Featured.webp)

For now I'll simply be assuming this will sort itself out when `python` is built complete with all its functionality. And
before anyone wants to point the finger at `clang`, you get the same result with `gcc`.

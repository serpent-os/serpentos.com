---
title: "Performance and Efficiency at the Forefront"
date: 2022-01-12T18:12:12+11:00
draft: false
Callout: "Squeezing out the most performance from your hardware"
---

<!---
Why:
- Improve energy efficiency for battery life
- You have better things to do than wait

How:
- Making Binaries More Efficient (boulder optimizations)
- Integrating benchmarking-tools
- From Theory to Practice! (applying benchmark tests/results to faster packages)
--->

Performance can mean different things to different people. For us, it is a cross between what is considered
traditional performance and efficiency. The core foundation of Serpent OS is to increase the performance of binaries and
libraries we distribute to you in **all** configurations. This provides users with greater energy efficiency so your
laptop lasts longer and generates less heat. Better battery is always a bonus and there's less waiting around for your
device.

# Making Binaries More Efficient

There's been plenty of strategies and techniques to boost the performance of benchmarks. For example, overclocking
allows you to get greater performance at a higher power draw. From the OS side, tuning the kernel with various CPU
schedulers can improve performance by putting the CPU to sleep less often, or not allowing it to reduce the frequency
during idle periods. A 1% increase in performance by increasing power draw by 5% makes an extremely poor OS default,
but looks great on a benchmark that only reports the time taken. Serpent OS has many tools at its disposal to squeeze
out more from your hardware.

Build system defaults:
 - Moving away from `x86_64-generic` baseline to the newer `x86_64-v2` as the minimum. This uses up to `SSE4.2` and has
   been around since 2010.
 - Creating multiple versions of packages so that newer supported CPUs can use more optimizations. Initially this means
   making `x86_64-v3+` packages to utilise `AVX2` and other extra instructions.
 - Preferring 128 bit vector width for `AVX` workloads by default. `AVX` and `AVX2` have shown to be outstanding
   performers, but only on select workloads (such as heavy math or machine learning software). This avoids the
   downsides of `AVX2` while allowing higher vector width where it provides maximum advantage.
 - `clang` compiler by default for packages.

`boulder` makes customizing the builds of individual packages easy:
 - Integrating profile guided optimization (PGO) workloads with only a couple of lines. This includes context
   sensitive 2 stage clang PGO.
 - Using link time optimizations (LTO) where possible.
 - The ability to use `gcc` for packages where a performance deficit is detected.

# Integrating benchmarking-tools

Solid benchmarking is a challenging process and requires a strong methodology and understanding what is creating the
difference in results. By integrating `benchmarking-tools` into Serpent OS, it allows us to test the performance of
packages we deliver to users. Some important features from integrating `benchmarking-tools` are:

 - Actually tests the software installed on your system by the distribution!
 - Few requirements to run in a minimal environment allowing us to compare multiple packages against each other, or
   even another distro in a chroot.
 - Can keep the system in a near identical state but with different versions of a single package.
 - Integrated `perf` result generation to give more clarity around performance differences.
 - Accessible to all users so they may run the same tests, or even add their own.

# From Theory to Practice!

Putting the two pieces together allows us to transition from academic theory, to better performance for your system.
By testing the performance of various knobs and features of `boulder`, we can identify ones that lead to better results
in most cases and roll them out as Serpent OS system defaults. This means that while we can't measure each and every
package, we can be confident that they are most likely benefiting from the performance tuning of packages we can
measure.

Allowing per package compiler flag changes through the tuning key in `boulder` means that we can try numerous
configurations for tuning a single package. Running each package through `benchmarking-tools` reveals the impact that
each option has on the performance via `perf`. While this can be a time consuming process, it is one that does happen
to ensure you get a lightning fast experience. Allowing users to easily run the benchmarks can validate that the
changes provide a benefit across varying hardware configurations.

# Check Out These Related Blog Posts:

- [RELR Brings Smaller Files, More Performance?](/blog/2022/04/05/relr-brings-smaller-files-more-performance) 5-Apr-2022
- [Performance Corner: Small Changes Pack a Punch](/blog/2021/12/14/performance-corner-small-changes-pack-a-punch) 14-Dec-2021
- [Performance Corner: Faster Builds, Smaller Packages](/blog/2021/11/05/performance-corner-faster-builds-smaller-packages) 5-Nov-2021
- [Initial Performance Testing](/blog/2021/08/02/initial-performance-testing) 2-Aug-2021

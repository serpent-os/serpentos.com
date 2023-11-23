---
title: "Performance Corner: Faster Builds, Smaller Packages"
date: 2021-11-05T19:23:32+11:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/performance-corner-faster-builds-smaller-packages/Featured.webp"
---

`Performance Corner` is a new series where we highlight to you some changes in Serpent OS that may not be obvious, but
show a real improvement. Performance is a broad term that also covers efficiency, so things like making files smaller,
making things faster or reducing power consumption. In general things that are unquestionably improvements with little
or no downside. While the technical details may be of interest to some, the main purpose is to highlight the real
benefit to users and/or developers that will make using Serpent OS a more enjoyable experience. Show me the numbers!

<!--more-->

Here we focus on a few performance changes `Ikey` has been working on to the build process that are showing some pretty
awesome results! If you end up doing any source builds, you'll be thankful for these improvements. Special thanks to
`ermo` for the research into hash algorithms and enabling our ELF processing.

# Start From the Beginning

When measuring changes, it's always important to know where you're starting from. Here are some results from a recent
`glibc` build, but before these latest changes were incorporated.

```
Payload: Layout [Records: 5441 Compression: Zstd, Savings: 83.13%, Size: 673.46 KB]
Payload: Index [Records: 2550 Compression: Zstd, Savings: 55.08%, Size: 247.35 KB]
Payload: Content [Records: 2550 Compression: Zstd, Savings: 81.46%, Size: 236.72 MB]
 ==> 'BuildState.Build' finished [4 minutes, 6 secs, 136 ms, 464 μs, and 7 hnsecs]
 ==> 'BuildState.Analyse' finished [21 secs, 235 ms, 300 μs, and 2 hnsecs]
 ==> 'BuildState.ProducePackages' finished [25 secs, 624 ms, 996 μs, and 8 hnsecs]
```

The build time is a little high, but a lot of that is due to a slow compiler on the host machine. But analysing and
producing packages was also taking a lot longer than it needed to.

# The Death of moss-jobs in boulder

In testing an equivalent build outside of `boulder`, the build stages were about 5% faster. Testing under `perf`, the
jobs system was a bit excessive for the needs of `boulder`, polling for work when we already know the times when
parallel jobs would be useful. Removing `moss-jobs` allowed for simpler codepaths using multiprocessing techniques from
the core language. This work is integrated in `moss-deps` and the excess overhead of the build has now been eliminated.

```
Before:
 ==> 'BuildState.Build' finished [4 minutes, 6 secs, 136 ms, 464 μs, and 7 hnsecs]
 ==> 'BuildState.Analyse' finished [21 secs, 235 ms, 300 μs, and 2 hnsecs]
After:
[Build] Finished: 3 minutes, 53 secs, 386 ms, 306 μs, and 4 hnsecs
[Analyse] Finished: 8 secs, 136 ms, 22 μs, and 8 hnsecs
```

The new results reflect a 26s reduction in the overall build time. But only 13s of this relates to the `moss-jobs`
removal. The other major change is making the analyse stage parallel in `moss-deps` (a key part of why we wanted
parallelism to begin with). Decreasing the time from 21.2s to 8.1s is a great achievement despite it doing more work as
we've also added ELF scanning for dependency information in-between these results.

# New Hashing Algorithm

One of the unique features in `moss` is using hashes for file names which allows full deduplication within packages,
the running system, previous system roots and for source builds with `boulder`. Initially this was hooked up using
`sha256`, but it was proving to be a bit of a slowdown.

Enter `xxhash`, the hash algorithm by Yann Collet for use in fast decompression software such as `lz4` and `zstd` (and
now in many places!). This is seriously fast, with the potential to produce hashes faster than RAM can feed the CPU. The
hash is merely used as a unique identifier in the context of deduplication, not a cryptographic verification of origin.
`XXH3_128bit` has been chosen due to it having an almost zero probability of a collision across 10s of millions of
files.

The benefit is actually two-fold. First of all, the hash length is halved from `sha256`, so there's savings in the
package metadata. This shouldn't be understated as hash data is generally not as compressible as typical text and there
are packages with a lot of files! Here the metadata for the Layout and Index payloads has reduced by 232KB! That's about
a 25% reduction with no other changes.

```
Before:
Payload: Layout [Records: 5441 Compression: Zstd, Savings: 83.13%, Size: 673.46 KB]
Payload: Index [Records: 2550 Compression: Zstd, Savings: 55.08%, Size: 247.35 KB]
After:
Payload: Layout [Records: 5441 Compression: Zstd, Savings: 86.66%, Size: 522.97 KB]
Payload: Index [Records: 2550 Compression: Zstd, Savings: 60.02%, Size: 165.75 KB]
```

Compressed this turns out to be about a 89KB reduction in the package size. For larger packages, this probably doesn't
mean much but could help a lot more with delta packages. For deltas, we will be including the full metadata of the
Layout and Index payloads, so the difference will be more significant there.

The other benefit of course is the speed and the numbers speak for themselves! A further 6.4s reduction in build time
removing most of the delay at the end of the build for the final package. This will also improve speeds for caching or
validating a package.

```
Before:
 ==> 'BuildState.Analyse' finished [21 secs, 235 ms, 300 μs, and 2 hnsecs]
After:
[Analyse] Finished: 1 sec, 688 ms, 681 μs, and 8 hnsecs
```

With these changes combined, building packages can take 12x less time in the analyse stage, while reducing the size of
the metadata and the overall package. We do expect the analyse time to increase in future as we add more dependency
types, debug handling and stripping, but with the integrated parallel model, we can minimize the increase in time.

{{<figure_screenshot_one image="performance-corner-faster-builds-smaller-packages/Featured" caption="">}}

# We're Not Done Yet

The first installment of `Performance Corner` shows some great wins to the Serpent OS tools and architecture. This is
just the beginning and there will likely be a follow up soon (you may have also noticed that it takes too long to make
the packages), and there's a couple more tweaks to further decrease the size of the metadata. Kudos to `Ikey` for
getting these implemented!

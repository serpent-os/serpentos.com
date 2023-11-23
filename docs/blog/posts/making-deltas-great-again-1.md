---
title: "Making Deltas Great Again! (Part 1)"
date: 2022-02-11T20:45:12+11:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/making-deltas-great-again-1/Featured.webp"
---

In [Optimising Package Distribution](/blog/2021/03/16/optimising-package-distribution) we discussed some early
findings for implementing binary deltas in Serpent OS. While discussing the implementation we have found the
requirements to be suboptimal for what we were after. We provide a fresh look at the issue and what we can do to make it
useful in almost all situations without the drawbacks.

<!--more-->

# Deltas Have a Bad Reputation

I remember back in the early 2000s on Gentoo when someone set up a server to produce delta patches from source tarballs
to distribute to users with small data caps such as myself. When requesting the delta, the job would be added to the
queue (which occasionally could be minutes) and then created a small patch to download. This was so important at the
time to reduce the download size that the extra time was well worth it!

Today things are quite different. The case for deltas has reduced for users as internet speeds have increased. Shrinking
20MB off a package size may be a second reduction for some, but 10 seconds for others. The largest issue is that deltas
have typically pushed extra computational effort onto the users computer in compensation for the smaller size. With a
fast internet connection that cost is a real burden where deltas take longer to install than simply downloading the full
package.

# What's so Bad About the Old Method?

The previous idea of using the full payload for deltas was very efficient in terms of distribution, but required changes
in how `moss` handles packages to implement it. Having the previous payload available (and being fast) means storing the
old payloads on disk. This increases the storage requirements for the base system, although that can be reduced by
compressing the payloads to reduce disk usage (but increasing CPU usage at install time).

To make it work well, we needed the following requirements:
- Install all the files from a package and recreate the payload from the individual files. However, Smart System
  Management allows users to avoid installing unneeded locale files and we would not be able to recreate the full
  payload without them.
- Alternatively we can store the full payloads on disk. Then there becomes a tradeoff from doubling storage space or
  additional overhead from compressing the payloads to reduce it.
- Significant memory requirements to use a delta when a package is large.

In short we weren't happy with having to increase the disk storage requirements (potentially more than 2x) or the
increase in CPU time to create compressed payloads to minimize it. This was akin to the old delta model, of smaller
downloads but significantly slower updates.

# Exploring an Alternative Approach

Optimal compression generally benefits from combining multiple files into one archive than to compress each file
individually. With `zstd` deltas, since you read in a dictionary (the old file), you already have good candidates for
compression matching. The real question was simply whether creating a delta for each file was a viable method for delta
distribution (packaged into a single payload of course).

As the real benefit of deltas is reducing download size, the first thing to consider is the size impact. Using the same
package as the previous blog post (but with newer versions of `QtWebEngine` and `zstd`) we look at what happens when you
delta each file individually. Note that the package is quite unique in that the largest file is 76% of the total package
size and that delta creation time increased a lot for files larger than 15-20MB at maximum compression.

|                 | Full Tarball | Individual Files | Full Tarball --zstd=chainLog=30 | Individual Files --zstd=chainLog=30 |
|-----------------|--------------|------------------|---------------------------------|-------------------------------------|
| Time to create  | 134.6s       | 137.6s           | 157.9s                          | 150.9s                              |
| Size of delta   | 30.8MB       | 29.8MB           | 28.3MB                          | 28.6MB                              |
| Peak Memory     | 1.77GB       | 1.64GB           | 4.77GB                          | 2.64GB                              |

Quite surprisingly, the delta sizes were very close! Most surprising was that without increasing the size of the
chainLog in `zstd`, the individual file approach actually resulted in smaller deltas! We can also see how much lower the
memory requirements were (and they would be much smaller when there isn't one large file in the package!). Our locale
and doc trimming of files will still work nicely, as we don't need to recreate the locale files that aren't installed
(as we still don't want them!).

The architecture of `moss` allows us to cache packages, where all cached packages are available for generating multiple
system roots including with our build tool `boulder` without any need for the original package file. Therefore any need
to retain old payloads or packages is no longer required or useful, eliminating the drawbacks of the previous delta
approach. The memory requirements are also reduced as the maximum memory requirement scales with the size of the largest
file, rather than the entire package (which is generally a lot bigger). There are many packages containing hundreds of
MBs of uncompressed data and a few into the GBs. But the largest file I could find installed locally was only 140MB, and
only a handful over 100MB. This smaller increase in memory requirements is a huge improvement and the small increase in
memory use to extract the deltas is likely to go unnoticed by users.

Well everything sounds pretty positive so far, there must be some drawback?

{{<figure_screenshot_one image="making-deltas-great-again-1/Featured" caption="">}}

# The Impact on Package Cache Time

As the testing method for this article is quite simplistic (`bash` loops and calls to `zstd` directly), the additional
overhead from creating deltas for individual files I estimated to be about 20ms compared to a proper solution. The main
difference from the old delta method is how we extract the payloads and recreate the files of the new package. Using the
full package you simply extract the content payload and split it into its corresponding files. The new approach requires
two steps, extracting the payload (we could in theory not compress it) and then applying patches to the original files
to recreate the new ones. Note that times differ slightly from the previous table due to minor variations between test
runs.

|                                      | Normal Package   | Individual Delta File Package |
|--------------------------------------|------------------|-------------------------------|
| Time to Delta Files                  | -                | 148.0s (137 files)            |
| Time to Compress Payload             | 78.6s            | 4.0s                          |
| Size of Uncompressed Payload         | 165.8MB          | 28.9MB                        |
| Size of Compressed Payload           | 51.3MB           | 28.6MB                        |
| Instructions to Extract Payload      | 2,876.9m (349ms) | 33.1m (34ms)                  |
| Instructions to Recreate Files       | -                | 1,785.6m (452ms)              |
|                                      |                  |                               |
| Total instructions to Extract        | 2,876.9m (349ms) | 1,818.7m (486ms)              |

What's important to note is that is this reflects a worst case scenario for the delta approach, where all 137 files were
different between the old and new version of the package. Package updates where files remain unchanged allows us to omit
them from the delta package altogether! So the delta approach not only saves time downloading files, but also requires
fewer CPU instructions to apply the update. It's not quite a slam dunk though as reading the original file as a
dictionary results in an increase in elapsed time of extraction (though the extra time is likely much less than the time
saved downloading 20MB less!).

In Part 2 we will look at some ways we can tweak the approach to balance the needed resources for creating delta
packages and to reduce the time taken to apply them.

```

Note: This was intended to be a 2 part series as it contains a lot of information to digest.
However, Part 2 was committed and follows below.

```

There's more than one way to create a delta! This post follows on from the earlier analysis of creating some basic
delta packages. Where this approach, and the use of `zstd`, really thrives is that it gives us options in how to manage
the overhead, from creating the deltas to getting them installed locally. Next we explore some ideas of how we can
minimize the caching time of delta files.

# Improving Delta Cache Time

To get the best bang for your buck with deltas, it is essential to reduce the size of the larger files. My experience in
testing was that there wasn't a significant benefit from creating deltas for small files. In this example, we only
create delta files when they are larger than a specific size while including the full version of files that are under
the cutoff. This reduces the number of delta files created without impacting the overall package size by much.

| Only Delta Files Greater Than        | Greater than 10KB | Greater than 100KB | Greater than 500KB |
|--------------------------------------|-------------------|--------------------|--------------------|
| Time to Delta Files                  | 146.1s (72 files) | 146.3s (64 files)  | 139.4s (17 files)  |
| Time to Compress Payload             | 3.9s              | 4.0s               | 8.3s               |
| Size of Uncompressed Payload         | 28.9MB            | 29.3MB             | 42.4MB             |
| Size of Compressed Payload           | 28.6MB            | 28.7MB             | 30.5MB             |
| Instructions to Extract Payload      | 37.8m (36ms)      | 34.7m (29ms)       | 299.1m (66ms)      |
| Instructions to Recreate Files       | 1,787.7m (411ms)  | 1,815.0m (406ms)   | 1,721.4m (368ms)   |
|                                      |                   |                    |                    |
| Total instructions to Extract        | 1,825.5m (447ms)  | 1,849.7m (435ms)   | 2,020.5m (434ms)   |

Here we see that by not creating deltas for files under 100KB, it barely impacts the size of the delta at all, while
reducing caching time by 50ms compared to creating a delta for every file (486ms from the previous blog post). It even
leads to up to a 36% reduction in CPU instructions to undertake caching through the delta than using the full package.
In terms of showing how effective this delta technique really is, I chose one of the worst examples and I would expect
that many deltas would be faster to cache when there's files that are exact matches between the old and new package. The
largest file alone took 300ms to apply the delta, where overheads tend to scale a lot when you start getting to larger
files.

There are also some steps we can take to make sure that caching a delta is almost always faster than the full package
(solving the only real drawback to users), only requiring Serpent OS resources to create these delta packages.

# Creating More Efficient Deltas

For this article, all the tests have been run with `zstd --ultra -22 --zstd=chainLog=30`...until now! The individual
file delta approach is more robust at lower compression levels to keep package size small while reducing how long they
take to create. Lets take a look at the difference while also ensuring `--long` is enabled. This testing combined with
the results above for only creating deltas for files larger than 10KB.

| Individual Delta File Package        | zstd -12         | zstd -16         | zstd -19         | zstd -22         |
|--------------------------------------|------------------|------------------|------------------|------------------|
| Time to Delta Files                  | 6.7s             | 113.9s           | 142.3s           | 148.3s           |
| Time to Compress Payload             | 0.5s             | 3.2s             | 5.3s             | 4.0s             |
| Size of Uncompressed Payload         | 41.1MB           | 30.6MB           | 28.9MB           | 28.9MB           |
| Size of Compressed Payload           | 40.9MB           | 30.3MB           | 28.6MB           | 28.6MB           |
| Instructions to Extract Payload      | 46.5m (35ms)     | 51.2m (28ms)     | 42.6m (33ms)     | 37.8m (36ms)     |
| Instructions to Recreate Files       | 1,773.7m (382ms) | 1,641.5m (385ms) | 1,804.2m (416ms) | 1,810.9m (430ms) |
|                                      |                  |                  |                  |                  |
| Total instructions to Extract        | 1,820.2m (417ms) | 1,692.7m (413ms) | 1,846.8m (449ms) | 1,848.7m (466ms) |

Compression levels 16-19 look quite interesting where you start to reduce the time taken to apply the delta as well
and only seeing a small increase in size. For comparison, at `-19` it only took 9s to delta the remaining 39.8MB of
files when excluding the largest file (it was 15s at `-22`). While the time taken between 19 and 22 was almost the same,
at `-19` it took 27% fewer instructions to create the deltas than at `-22` (`-16` uses 64% fewer instructions than
`-22`). It will need testing across a broader range of packages to see the overall impact and to evaluate a sensible
default.

As a side effect of reducing the compression level, you also get another small decrease in the time to cache a package.
The best news of all is that these numbers are already out of date. Testing was performed last year with `zstd` 1.5.0,
where there have been notable speed improvements to both compression and decompression that have been included in newer
releases. Great news given how fast it is already! Here's a quick summary of how it all ties together.

# Delta's Are Back!

This blog series has put forward a lot of data that might be difficult to digest...but what does it mean for users of
Serpent OS? Here's a quick summary of the advantages of using this delta method on individual files when compared to
fetching the full packages:

- Package update sizes are greatly reduced to speed up fetching of package updates.
- `moss` architecture means that we have no need to leave packages on disk for later use, reducing the storage
  footprint. In fact, we could probably avoid writes (except for the extracted package of course!) by downloading
  packages to `tmpfs` where you have sufficient free memory.
- Delta's can be used for updating packages for packaging **and** your installed system. There's no need for a full
  copy of the full original package for packaging. A great benefit when combined with the source repository.
- Delta's are often overlooked due to being CPU intensive while most people have pretty decent internet speeds. This has
  a lot to do with how they are implemented.
- With the current vision for Serpent OS deltas they will require fewer CPU instructions to use than full packages, but
  may slightly increase the time to cache some packages (but we are talking ms). But we haven't even considered the
  reduction in time taken to download the delta vs the full package which more than makes up the difference!
- The memory requirements are reduced compared to the prior delta approach, especially if you factor in extracting the
  payload in memory (possibly using `tmpfs`) as part of installation.

# Getting More Bang for Your Buck

There's still plenty more work to be done for implementing delta's in Serpent OS and they likely aren't that helpful
early on. To make delta packages sustainable and efficient over the long run, we can make them even better and reduce
some wastage. Here are some more ideas in how to make deltas less resource intensive and better for users:

- As we delta each file individually, we could easily use two or more threads to speed up caching time. Using this
  package as an example, two threads would reduce the caching time to 334ms, the time the largest file took to recreate
  plus the time to extract the payload. Now the delta takes less time and CPU to cache than the full package!
- `zstd` gives us options to tradeoff some increase in delta size to reduce the resources needed to create delta
  packages. This testing was performed with `--ultra -22 --zstd=chainLog=30` which is quite slow, but produces the
  smallest files. Even reducing the compression level to `-16 --long` didn't result in a large increase in delta size.
- We always have the option to not create deltas for small packages to ease the burden, but in reality the biggest
  overhead is created from large files.
- When creating deltas, you typically generate them for multiple prior releases. We can use smart criteria when to stop
  delta generation from earlier releases for instance if they save less than 10% total size or less than 100KB. A delta
  against an earlier release will almost always be larger than versus a more recent release.

# Even Better than These Numbers Suggest

While the numbers included have been nothing short of remarkable, they don't quite reflect how good this approach will
be. The results shown lack some of the key advantages of our delta approach such as excluding files that are unchanged
between the two packages. Other things that will show better results are:

- When package updates include minimal changes between versions (and smaller files), we would expect the average package
  to be much closer in elapsed time than indicated in these results.
- A quick test using a delta of two package builds of the same source version resulted in a 13MB delta (rather than the
  28.6MB delta we had here). On top of that it took 62% fewer CPU instructions and less time (295ms) than the full
  package to extract (349ms) without resorting to multi-threading.
- Delta creation of the average package will be quite fast where the largest files are <30MB. In our example, one file
  is 76% of the package size (126MB) but can take nearly 95% of the total creation time!
- We will be applying features to our packages that will reduce file sizes (such as the much smaller RELR relocations
  and identical code folding), making the approach even better, but that will be for a future blog post.

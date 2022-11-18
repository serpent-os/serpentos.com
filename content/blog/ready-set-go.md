---
title: "Ready, Set, Go"
date: 2022-11-18T18:07:25+11:00
draft: false
type: "post"
authors: [sunnyflunk]
categories: [news]
featuredImage: "/img/blog/ready-set-go/Featured.webp"
---

While the blog has been quiet, the git commits have been flowing! The core pieces of our infrastructure are nearing
the testing phase - a complete workflow for developers to submit and build packages and for them to become available in
the Serpent OS repo. At this point we can get many more contributors involved in packaging while circling back to make
it more automated and efficient for them.

<!--more-->

By respecting the time of contributors, we can get more done in the same time, utilise and manage more contributions to
reduce the workload on everyone. This also makes Serpent OS an attractive platform for new contributors and enables more
users to get involved by making packaging so easy.

**TL:DR - With the infrastructure and tooling almost in place, the bringup of Serpent OS begins**

# The Long Road Reaps Rewards

What we have done is worked on getting all the tools and infrastructure in place before trying to release anything
installable to users. Experience has shown that large refactors or complete rebuilds of the tools are difficult to
pursue and take years to eventuate (if at all). This means that efforts can now go towards making the distribution
you've been waiting for without having issues scaling or tools that need a rewrite due to hurting the experience of
contributors.

Going forward users and developers will see tangible benefits from the work put into Serpent OS without significant time
spent on the hidden parts of the distribution (which are essential but time consuming). This is not to say that they are
feature complete, but that the focus can be on making visible improvements to people's Serpent experience.

From a fundraising point of view, this has meant it has taken longer to get a usable ISO into your hands...but the
benefits will be seen for years to come.

# `summit` - Managing the Distribution

At a high level, `summit` sits in the middle of everything, communicates with our other tools `avalanche` and `vessel`,
and provides an overview of the project and what's happening within it via dashboards. When a build is generated,
`summit` fetches the build information, determines the optimal build order, finds a builder to create the package and
then lets `vessel` know when it's ready to enter the main repository. This is all backed by authentication to ensure
only authorised users and builders are used to maintain security.

Our build files are backed by git repositories on GitHub, where `summit` brings the important information much closer to
developers. Our git repositories are organised into logical groups representing the delegation of responsibilities. For
example, we can add many more developers to our `plasma` group and enable them to push builds directly where we may not
want them to modify the toolchain or kernel without a second review.

`summit` also parses information from git to display in an easy to consume format. Here we see an example of the
metadata page of the `ccache` package.

![Metadata](/static/img/blog/ready-set-go/Metadata.webp "Metadata")

# `avalanche` - Builder as a Service

`avalanche` runs as a service ready to accept builds from `summit`. It is low overhead and monitors the state of the
machine via a dashboard so if the builder were to run out of disk space or stall it will be easily seen by the
`avalanche` owner. This makes it very easy for people to spin up a builder and will eventually be utilised for people
who lack powerful hardware to test builds on before submitting as official packages. Note that distribution packages
will only be built on the most trusted builders and test builds will be made to ensure the correctness of all
`avalanche` builders is maintained.

![Avalanche](/static/img/blog/ready-set-go/Avalanche.webp "Avalanche")

There are many use cases for `avalanche`, where we can partition system resources via `systemd-nspawn` instances to
provide multiple builders on one host. Many builds only utilise a few cores, so it becomes more efficient to run
multiple builders concurrently. As builds are isolated from the host, `avalanche` instances can easily be run on
bare metal or in a container/VM if preferred.

Once a build is completed, `avalanche` is responsible for reporting completion to `summit`. `summit` then instructs
`vessel` to fetch the build artefacts from the relevant `avalanche` instance.

This design decision allows `summit` to schedule a new build to the `avalanche` instance as soon as it has reported
completion of the prior build, thus allowing for maximum use of both upload and download bandwith for each `avalanche`
instance -- and as a direct consequence, higher overall build throughput across the entire set of builders.

# `vessel` - Making Packages Available to Users

`vessel` is a fairly simple (but very important) part of the build infrastructure. After fetching a package from a
a builder, `vessel` will then update its index with the newly minted package, thus making the package available in
our official repository for installation.

In future `vessel` will be expanded to support versioned indexes (making each update a new release) and branches to
enable testing new features complete with rollback that `moss` supports across all updates.

# Enabling Faster Packages!

Feature work has started on adding ISA levels to enable support for adding `x86-64-v3x` packages. This can provide extra
performance and reduced power use for supported CPUs (this denotes the `x86-64-v3` psABI with some extra e**x**tensions
that your processor will likely also include). As we aren't relying on the `glibc` hwcaps feature, we have the ability
to adjust the featureset to the benefit of our users. Once we have a `x86-64-v4` builder available, we can also look at
providing an extra layer for packages that heavily utilise math. This will be the result of actual benchmarks to
indicate which packages provide additional performance from their newer CPU features.

With the infrastructure already supporting multiple builders (and an optimised toolchain to minimise build time), adding
more architectures will not pose any capacity issues.

---
title: "System Management Tool For Serpent OS"
date: 2022-02-18T18:13:46+11:00
draft: false
Callout: "`moss` is much more than just a package manager"
---

<!---
Why:
- Amalgamation and extension of other PM's
- Take the good parts and wrap it in performance
- The ultimate Distro management tools

What:
- The Basics of System Layout (deduplication etc)
- Blitting Makes Serpent OS Atomic
- `moss-format`: What Makes Up a Package?
- `moss-triggers`: Smarter Post-Install Triggers
- Smart System Management (link to the smart.md page)
- Reproducible System States With Versioned Repos (mentioned on flexible page)
- Binary Versus Source Builds
- Deltas Make For Small Updates
- Logical Dependency handling
--->

The ideas behind `moss` are not original, but are refined and combined into a single package manager. In fact it's much
more than a package manager! By taking all the good parts and extending the features we are left with the ultimate
distro management tools! And what good would it be if we didn't also make it extremely fast!

# The Basics of System Layout

`moss` stores packages on disk as a unique hash of every file. In Serpent OS, we call this `caching` a package which
includes adding the package metadata to the corresponding databases. This differs to installation as the files aren't
yet available for the user to access. Therefore we can `cache` a package at any time without impacting on the running
system.

From there, we can make up an entire system state (the `/usr` directory) by creating hardlinks in the `moss` store to
build up a complete `/usr` directory for the system. We call this process `blitting` and is the step that makes `cached`
packages available to the user. Once we have created a system state, it is now ready to be accessed via a symlink.
For example, here we see the `/usr` directory as a pointer to the `moss` store (`usr -> .moss/store/root/1/usr`). From
the users perspective, it will just work like a traditional file system layout, but with much more flexibility.

# Blitting Makes Serpent OS Atomic

The update process is fully atomic, where `caching` occurs separately in the background and `blitting` creates a system
state in the `moss` store before it has any impact on the users system. If there's a power outage or interruption of
this process, there's no problem at all. Your original `/usr` directory will still be in place when you reboot and
rerunning the update will then create a fresh system state. This makes transactions with `moss` dependable, simple and
fast!

As a result, when updates occur, the previous system state remains on the system allowing for easy rollbacks if there's
anything at all that you don't like. Just change the symlink back and you've got your system back just like that. This
allows for easy testing of changes including a whole branch of updates!

For bigger updates you will need to reboot in order to start running the new system, but the update can be prepared
beforehand so won't be waiting longer than your usual reboot time for the update to complete.

# `moss-format`: What Makes Up a Package?

A `.stone` package is made up of four payloads:

 - **Meta Payload:** Contains the usual metadata of a package including its dependencies.
 - **Layout Payload:** This includes all the information to apply a `cached` package to the system. Includes the file
   hash, the path of the file (in `/usr`) and the file's permissions.
 - **Index Payload:** Includes the size and hashes of files in the content payload. This is used for `caching` a
   package, and is not needed to be stored afterwards.
 - **Content Payload:** The files of the package concatenated together. Relies on the index payload to make sense of its
   contents.

This differs a lot from traditional tarball packages, where each payload is compressed individually. Despite this, it is
very efficient by comparison allowing for smaller package sizes. As the format is designed specifically for Serpent OS,
every aspect can be tuned for function and performance.

# `moss-triggers`: Smarter Post-Install Triggers

Post-install package triggers have long been used by Linux distros, but aren't really needed. `moss-triggers` removes
post-install scripts from packages by taking care of the functions in `moss` when state data needs to be updated after
package updates. The requirements for post-install operations are entirely predictable, if you add or remove icons, you
need to update the icon cache. If changing libraries, it will run `ldconfig` to update the cache for faster binary
loading. This makes life easier for packagers and keeps the system in optimal working condition.

# Smart System Management (SSM)

We already have a pretty in-depth discussion on how `moss` takes care of system through SSM. See our
[Smart System Management](/smart) page for the full details.

# Reproducible System States With Versioned Repos

With a rolling release distro, there are instances where users don't always want the latest versions of software. Maybe
they aren't ready for the changes in the new version of a database. Downgrading or holding back package updates results
in a partial update. These are difficult to support and quickly get complicated where new updates aren't built to work
with the software you have installed locally.

Versioned repos solve this issue by creating `checkpoints`, that is a static set of packages at a particular time that
are all built to work with each other. This means that if you don't update to the latest version, you can still install
extra software that you know with work with your slightly older packages. While most of the time you'll want to be on
the latest release, this is a handy feature to have for the times it's needed.

Versioned repos are a fantastic feature when it comes to bugfixing as you can reproduce the set of packages of a user
in a given state, even if it was from last month. This allows one to reduce the causes of the bug to a minimal set of
packages.

# Binary Versus Source Builds

`moss` operates as a source distribution with pre-built binary packages used where available. Pre-built binary packages
will be available for the main Serpent OS repository, but as it's focused on source builds, opens up opportunities to
easily add and share new packages with others. Instead of asking someone to install a binary package (where you can't
validate that the contents haven't been altered), you can build the package on the host machine instead.

This makes adding source repos simple and easy, hence having a community source repo for people to share their builds
without having to setup a build server to create and serve the output `.stone` files.

# Deltas Make For Small Updates

Where pre-built binary packages are available, there's also the ability to provide delta packages to minimize update
size. Deltas are very effective on Serpent OS, as due to the unique way that `moss` works there's no need to recreate
packages before applying an update. This makes them extremely fast and efficient to use, and always better than simply
downloading the full package. There's no trade-off for whether they are worthwhile, to reduce download size by
increasing CPU use for an update. Serpent OS deltas are able to reduce both! Through the use of `zstd`, we can even
produce deltas for binary files to really make updates smaller.

# Check Out These Related Blog Posts:

- [Making Deltas Great Again!](/blog/2022/02/11/making-deltas-great-again-part-1) 11-Feb-2022
- [It All Depends](/blog/2021/11/23/it-all-depends) 23-Nov-2021
- [Optimal File Locality](/blog/2021/10/04/optimal-file-locality) 4-Oct-2021

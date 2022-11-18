---
title: "A Rolling Boulder Gathers No Moss"
date: 2021-08-10T12:02:37+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/a-rolling-boulder-gathers-no-moss/Featured.webp"
---

We actually did it. Super pleased to announce that `moss` is now capable
of installing and removing packages. Granted, super rough, but gotta start
somewhere right?

<!--more-->

{{<figure_screenshot_one image="a-rolling-boulder-gathers-no-moss/Featured" caption="Transactional system roots + installation in moss">}}

OK let's recap. A moss archive is super weird, and consists of multiple
containers, or payloads. We use a strongly typed binary format, per-payload
compression (Currently `zstd`), and don't store files in a typical archive
fashion.

Instead a `.stone` file (moss archive) has a Content Payload, which is
a compressed "megablob" of all the unique files in a given package. The
various files contained within that "megablob" are described in an IndexPayload,
which simply contains some IDs and offsets, acting much like a lookup table.

That data alone doesn't actually tell us **where files go** on the filesystem
when installed. For that, we have a specialist Layout Payload, encoding the
final layout of the package on disk.

As can be imagined, the weirdness made it quite difficult to install in
a trivial fashion.

# Databases

Well, persistence really. Thanks to `RocksDB` and our new `moss-db` project,
we can trivially store information we need from each package we "precache".
Primarily, we store full system states within our new StateDB, which at
present is simply a series of package ID selections grouped by a unique
64-bit integer.

Additionally we remember the layouts within the LayoutDB so that we can
eventually recreate said layout on disk.

# Precaching

Before we actually commit to an install, we try to precache all of the stone
files in our pool. So we unpack the content payload ("megablob"), split it
into various unique files in the pool ready for use. At this point we also
record the Layouts, but do not "install" the package to a system root.

# Blitting

This is our favourite step. When our cache is populated, we gather all
relevant layouts for the current selections, and then begin applying them
in a **new** system root. All directories and symlinks are created as normal,
whereas any regular file is hardlinked from the pool. This process takes a
fraction of a second and gives us completely clean, deduplicated system roots.

Currently these live in `/.moss/store/root/$ID/usr`. To complete the transaction,
we update `/usr` to point to the new `usr` tree **atomically** assuming that
a reboot isn't needed. In future, boot switch logic will update the tree for us.

# Removal

Removal is quite the same as installation. We simply remove the package IDs
from the new state selections (copied from the last state) and blit a new
system root, finally updating the atomic `/usr` pointer.

![Removal](/static/img/blog/a-rolling-boulder-gathers-no-moss/Removal.webp "Removal of packages with moss. Everything is a transaction")

# Tying it all together

We retain classic package management traits such as having granular selections,
multiple repositories, etc, whilst sporting advanced features like full system
deduplication and transactions/rollbacks.

When we're far enough along, it'll be possible to boot back to the last working
transaction without requiring an internet connection. Due to the use of pooling
and hardlinks, each transaction tree is only a few KiB, with files shared between
each transaction/install.

# On the list..

We need some major cleanups, better error handling, logging, timed functions,
and an eventloop driven process to allow parallel fetching/precaching prior
to final system rootfs construction.

It's taken us a very long time to get to this point, and there is still more
work to be done. However this is a major milestone and we can now start
adding features and polish.

Once the required features are in place, we'll work on the much needed
pre alpha ISO :) If you fancy helping us get to that stage quicker, do
check out our OpenCollective! (We won't limit prealpha availability,
don't worry :))

{{<oc>}}

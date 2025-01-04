---
title: Offline Rollbacks Enabled
date: 2025-01-04T22:19:37Z
authors: [ikey]
categories: [news]
---

If a picture tells a thousand words... well then this video .. Yknow what, sod it.
Here's a video of the offline rollback support in action, as tested in a newly installed
VM using `xfs` for the root filesystem. We jokingly refer to this as the "LTT" test due
to LinusTechTips' "interesting encounters" with package management systems in the past.

This has already landed in our volatile repository, so simply `sudo moss sync -u` and grab
the latest updates. Any subsequent transactions will automatically generate the boot entries
for you, no intervention required. Or mounting. Or anything. Just update and go. Srsly.

{{< youtube qkErsc4CA24 >}}

We actually saw this as a golden standard for the feature, as it's a real-world scenario
where you'd want to roll back to a known good state. The video shows the system booting
and recovering in multiple ways, from complete system nuke (via glibc) and simpler scenarios
like removal of the GNOME desktop environment.

The intent is to ensure a user can quickly revert to the last transaction that worked in the
instance an update goes awry, without needing to boot into a rescue environment or live CD.

<!--more-->


### Like what we're doing?

Developing a project with the scope of Serpent OS is no small feat. In order to maintain our
current cadence, and to land huge features like the offline rollback, or impending system
model work, we need your support. I'm as happy as the next person to return to the job market
once my medical conditions ease up, but the simple matter is this will greatly slow down our
recent progress.

Our aim is to entirely redefine the **distribution** of Linux, and the years of prior effort
are finally coming together rapidly to make this a reality. If you like what we're doing,
consider supporting us!

{{< kofi >}}


Visit our [sponsor](/sponsor) page for more information on how you can help us grow and deliver
the future of Linux distributions.

### Technical Details

This is all achieved using moss's internal content addressable storage for deduplication,
where each old transaction is swapped with the live `/usr` at the time into the archive.

The behaviour is implemented in the initramfs (`dracut`) by invoking `moss state activate $transaction_id -D /sysroot`,
ensuring that the activation is performed *before* the new root is mounted and the system is booted.
We actually shrunk our `moss` and `uutils-coreutils` builds to half their usual size so that we can
fit them comfortably into the initramfs.

For now, we'll automatically generate entries on the ESP (or XBOOTLDR) for the last 5 transactions, and you
can select them during early boot to perform the rollback. It's not slow, as it's just doing yet another
`renameat2()` to atomically exchange the live `/usr` with the archived transaction.

TLDR: Boot time rollback, no network required, no live CD required, no rescue environment required. Just a working system.

### What's next?

The system model is coming next, which will expose the non-imperative core of the architecture to users.
The usual commands will continue to emulate an imperative OS, by mutating the system model and applying
the internal `sync` operation. This ensures dependencies are resolved only according to the layered repository
configuration, without special exceptions for "installed" (which.. we spent a lot of effort faking this behaviour).

It's good to remember that moss is effectively a huge cache, and that each state has no relation to the other. We
simulate upgrades by building a new state with the same selections as the old one, then begin to upgrade those candidates.

The new model (somewhat Gentoo inspired ❤️) will allow moss to build the dependency graph for the finished system state.
As a sneak preview of what we're enabling, imagine the newly landed transactional reboot code linked with **multiple**
system models... such that you might decide to `moss sync` from your existing model to an entirely different one, rebooting
from your GNOME desktop to a KDE desktop, for example. Cleanly, atomically, and without any manual intervention.

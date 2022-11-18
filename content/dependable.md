---
title: "Dependability You Can Count On"
date: 2022-01-05T09:03:23+11:00
draft: false
Callout: "Our mission is to keep you running without the hassle"
---

<!---
Why:
- Keep you running without the hassle
- Help you get back and running easily after breaking the system

How:
- Reliable Atomic Updates
- Checkpoints Provide Immutable Mini Releases
- Integrated Test(ing) Coverage
--->

The Serpent OS team understands that there's more to life than making an OS. Our mission is to keep you running without
the hassle, so you can get done what you need to. If you do encounter an issue, you can reboot right back to your
previous working state!

# Reliable Atomic Updates

Partial updates are a thing of the past with `moss` allowing for atomic updates of your system. This reduces the chances
of things going wrong during the update process (such as loss of power). Your system will reload into its previous state
as if the update never started! It also allows us to change out the `libc` on a reboot if we should want to in the future.

Serpent OS makes using a rolling release safer by:
 - Read only rootfs for improved security. System installed packages are not able to be altered during normal operation,
   keeping it separate and secure from your daily activities. Better yet, the layout still feels like a normal Linux
   distribution.
 - Atomic updates via `moss`. With utilizing multiple system roots, not only do you get free rollbacks of updates, but
   an update only relies on the changing of a single pointer once it is ready.
 - Rollback an update by selecting the previous option from the boot menu and return to the prior system state.

# Checkpoints Provide Immutable Mini Releases

Checkpoints are an interesting feature in a rolling release, where you define a state of a fixed set of packages that
make up a mini release. This means that not only can you rollback from a previous update, but you can recreate a Serpent
OS system back to a prior checkpoint you have never installed before.

Advantages of the checkpoint system:
 - Reproduce bugs at prior checkpoints, so you can identify the smallest set of changes which introduced the bug.
 - Remain on an older checkpoint till you are ready to transition to new software releases.
 - Create checkpoints from feature branches, allowing you to switch back and forth between them to test upcoming
   features.
 - Install a prior checkpoint that is has been widely tested and deployed through your organization.

# Integrated Test Coverage

Broad but simple testing of packages is deployed for as many of the packages as feasible. This can range from aggressive
unit testing during the build, to running the binaries to check for any runtime deficiencies (for example missing
dependencies, or needing a rebuild). If you want the best experience you can enjoy user testing of checkpoints via the
`edge` branch prior to them being released more widely.

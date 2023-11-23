---
title: "Smart System Management (SSM)"
date: 2022-01-12T19:31:14+11:00
draft: false
Callout: "Making intelligent decisions behind the scenes without interruption"
---

<!---
Why:
- Avoid known bugs from package dependencies
- Reduce your OS footprint making updates even faster
- Minimize support requests and documentation needs, moss sorts it out for you

How:
- Got Your Hardware Covered! (auto v3+ selection)
- moss Knows What You Need (smart dependencies)
- Slim Down Your OS (not installing locales/docs)
- Customize Your System Without Rebuilding Packages (multi-package opt in to things like `minimal` versions of packages)
--->

Smart System Management (SSM) covers a range of features that improve how `moss` handles your Serpent OS experience to
make it as simple as possible. It reduces support requests by introducing smart dependencies, where there is more than a
1-to-1 relation between packages. For example, questions like "Why can't I run Steam?" followed by, "Do you have the
32-bit graphics drivers installed?". We know you need them, so lets install them before you hit the problem!

Users can also benefit from a slimmer OS footprint by removing files that you don't need. The number of improvements
will only increase with more ideas from the community!

# Got Your Hardware Covered!

Knowing the right packages to install to get the most of your hardware can be tricky. There's plenty of guides online,
but are usually specific to one distro. We could also make a guide specific to Serpent...or we could integrate it
straight into `moss`!

Here's a couple of ideas of how `moss` will take out the guesswork:
 - **Optimized, CPU specific packages:** Serpent OS will start off with `x86-64-v2` packages. However, we won't settle with
   the performance where you have a newer processor. `moss` can detect if your CPU is compatible with `x86-64-v3+`
   packages, and install those packages where they are available. You won't have to lift a finger!
 - **Capability based:** This includes hardware specific requirements to get you the best drivers and modules, regardless of
   who made your system. No longer do we need to include packages where we can obviously determine whether you will need
   (or not need) a package based on your installed hardware. For example, we can automatically install the `VA`/`VA-API`
   packages for your brand of hardware, but not include all versions for all hardware (which usually occurs).

# moss Knows What You Need

SSM allows `moss` to create dependencies beyond the traditional 1-to-1 relationship that is typically used. There is no
need for optional or recommended dependencies. Every distribution is different in terms of package names and SSM allows
you to start using your system without knowing much about how `moss` works (though I highly recommend it for the curious
types).

Here are some examples of how the smart dependencies can handle situations, so you don't need to search for solutions:
 - Install 32-bit graphics drivers when you have `steam` or `wine` installed. While this can happen automatically for
   the mesa drivers, it's not automatic for the `NVIDIA` drivers as installing them will break systems without
   supported hardware. `moss` can make this dependency automatic for any system that has the 64-bit binary graphics
   drivers installed.
 - Install the `dolphin` plugins for `nextcloud` when you have both programs installed, but don't install all the `KDE`
   dependencies of the plugins when you don't use `dolphin`. Rather than an optional dependency, this becomes a smart
   one while keeping the dependencies of each package complete.
 - Some software requires separate kernel modules, but how do you know which version to install? Smart dependencies
   takes away the need for documentation. You choose the software, `moss` will get you the right kernel modules.

# Slim Down Your OS

SSM reduces the number of files that you need installed on your system, reducing the cruft and OS footprint of your
system. Packages frequently include files that you may never use. For files like locales of other languages, `moss` can
simply not install them. This doesn't mean more work for packagers as locale files are very compressible so will still
be included in the same package in most cases. The difference is, that across a whole system of packages, that can
easily add up to 1 GB of unwanted locales.

Ways that `moss` can slim down your system:
 - **Locale based:** Language and translation files can take up quite a chunk of space on a system. They also make up a
   large number of files, so will increase the speed of package transactions via `moss` when excluding them.
 - **Documentation:** While documentation is very useful, many of us go straight to the search engine to read up on it
   online. For those kind of users, we can free up a bit of disk space!

# Customize Your System Without Rebuilding Packages

In theory, there's no limit to what you can achieve via SSM. By combining the efforts of our community, we can add more
ideas and allows users to differentiate without all the hard work. As an example, you could opt into a `minimal`
system to install slimmed versions of some packages.

Here are a couple of ideas of how it might work, while integrating into upstream packages:
 - Split a package to separate files or plugins with large dependencies for features that you may not even need. Think
   of a plugin pulling in `QtWebEngine` just to display webpages in a desktop widget. A useful feature for some, but
   unneeded for others.
 - Provide a `minimal` experience for a desktop environment. This would be a smaller set of packages while retaining the
   core functionality, but without extras that you might not use.
 - Reducing features would need to be opt-in. So users will be aware why some features would be missing.

There are many possibilities in how SSM makes your Serpent OS experience better. It's as simple as set and forget, but
for those that want to customize more deeply, they have tools available for them to do so, while getting the traditional
experience of a flexible system without having to recompile core packages.

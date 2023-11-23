---
hide:
    - toc
    - navigation
    - footer
title: Home
---

# :rocket: Blazing Fast System Management

Whether you're using Linux for home or work, we've got you covered. Don't wait around for old package managers
or bundles: turbocharge your installations and containers with [moss](/moss) and Serpent OS.

Serpent OS is an `x86_64-v2+` (`v3+` coming soon) Linux distribution built around the [LLVM](https://llvm.org) toolchain and our
vision of how Linux should be distributed, using our next-generation content-addressable package manager, fully
stateless design and modern approach to deployment. Our ideals and practices are founded on 20+ years of distribution
engineering experience.

[:fontawesome-solid-gift: Sponsor us!](/){ .md-button }

![In action](static/Landing.webp)


!!! danger "Serpent OS is in active, heavy development"

    We welcome all contributions at this stage of our development, as we transition from prototypes to deliverables,
    especially with our transition to Rust. With the integration of system triggers nearing, we'll begin to publish
    frequent desktop ISOs and OCI images for dog-fooding purposes.

## :atom: Atomic transactions

Every package management operation creates an entirely self contained transaction, offering rollbacks to earlier points in
time as well as ensuring new updates are safe to apply. Unlike other "A/B" transaction systems, `moss` can make the new
system root available immediately.

## :zap: Ridiculously fast

We leverage the fastest technologies and techniques to provide *ridiculously* fast package management.

 - [xxHash](https://xxhash.org) for content addressable hashes. Zip!
 - [Zstandard](https://github.com/facebook/zstd) for package compression, kernel modules, firmware, etc.
 - Upcoming: Blake3 for verification!
 
## :hammer: Superpowered packaging

Our simple  yet powerful `stone.yml` format makes it a breeze to create packages for Serpent OS. Whip them through [boulder](/boulder), our
container-based build-tool, and have binary packages in no time.

No steep learning curve, just some YAML and an extremely intelligent package build system capable of automatically splitting packages into
the correct subpackages and creating their dependencies. Heck, we can even generate a recipe from an upstream release! :astonished:

## :lock: Safer

 - :crab: Core tooling written in Rust, others being actively ported. Memory safe, and extremely fast execution.
 - :warning: Self-contained static builds of essential system tools (musl+static) - even glibc can be recovered.

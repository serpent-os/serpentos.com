---
title: Moss
---

{{% blocks/lead color="primary" %}}
# moss

{{% /blocks/lead %}}

{{% blocks/section color="background" %}}
Instead of relying on multiple layers of tools to achieve our aims of a composition-first,
atomically updating OS, we created our own solution: [moss](https://github.com/serpent-os/moss).

moss looks and feels a lot like a regular package manager, however it actually manages the entire
operating system via content addressable storage. Every single file from every package is deduplicated
via a hash-based addressing scheme in the moss store, allowing us to produce new system roots on the fly.

In practice, this means that for every **transaction**, we can efficiently create an entirely new root
filesystem tree using shared assets, for low-cost, filesystem-agnostic "snapshots". Thanks to some clever
scaffolding and design we can then **immediately** activate the new transaction as the system root without
requiring a reboot:

  -  Generate new `/usr` under `/.moss/root`
  - "Activate" via a `renameat2()` (`ATOMIC_EXCHANGE`) call to swap live `/usr` with `/.moss/root/$ID`

In order to achieve this, we mandated that any package build must only contain files in `/usr`, which also
means all packages in Serpent OS are **stateless**. That also adds some complexities such as running transactional
scoped "triggers" in namespace, and separating from so-called "system triggers".

Additionally we required a type-safe binary format for storing our packages, emitted by `boulder`. This creates
`.stone` archives that are internally deduplicated, use `zstd` compression and `xxhash` for content addressing.
For more information, please see the [stone format documentation](https://docs.serpentos.com/docs/category/stone-format).

With that said, we think we've done a pretty good job at keeping these internals tidy and presenting a classical
feeling package manager that doesn't sacrifice on user choice or require a steep learning curve, all while providing
next generation features like atomic updates and content addressable storage, natively.

{{% /blocks/section %}}

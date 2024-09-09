---
title: Tooling
toc_hide: true
---

{{% blocks/lead color="primary" %}}
# Tooling

{{% /blocks/lead %}}

{{% blocks/section color="background" %}}

Here at Serpent OS, we love good tooling. Our language of choice is [Rust](https://rust-lang.org)
for creating lightning quick tooling with high cadence feature work and minimal debt. Our belief
is that by providing great tooling, the overall maintainer load is greatly reduced, allowing everyone
to enjoy a greater developer and user experience.

{{% /blocks/lead %}}

{{% blocks/section type="row" color="info" %}}

{{% blocks/feature icon="fa fa-box-archive" title="**moss** - package management" url="/moss" %}}
The star of the show is certainly moss, the package and system management tool. With **atomic updates** and
**deduplication** at the core of the design, it delivers with performance and reliability.

{{% /blocks/feature %}}

{{% blocks/feature icon="fa fa-trowel" title="**boulder** - build tooling" url="/boulder" %}}
The build partner for moss is boulder, an extremely powerful, flexible and easy to use package build tool.
Making use of a simple `YAML` format and enriched shell scripts, building consistent packages has never been easier.

{{% /blocks/feature %}}

{{% blocks/feature icon="fa fa-hard-drive" title="**blsforme** - boot management" url="https://github.com/serpent-os/blsforme" %}}
Nobody should need to manage their boot configuration manually. That's exactly why moss leverages the blsforme project
to automatically manage the EFI System Partition (and `XBOOTLDR`..) and manage boot entries.
{{% /blocks/feature %}}

{{% /blocks/section %}}

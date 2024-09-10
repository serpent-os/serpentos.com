---
title: boulder
---

{{% blocks/lead color="primary" %}}
# boulder

{{% /blocks/lead %}}

{{% pageinfo color="warning" %}}
This page is awaiting further enhancement.
{{% /pageinfo %}}

{{% blocks/section color="background" %}}

Building on top of the foundations of moss, we needed a lightning quick tool for building packages so that we can
easily scale up to deliver important updates for our users. We also needed a slick developer experience with heavy
caching capabilities, and a familiar build *recipe* format anyone can jump into.

To do so, we created `stone.yaml`. This YAML file contains some basic metadata, along with rich, shell-based build
steps complete with centrally configured **macros** for easily creating package builds in a distro-consistent fashion.
It is designed as a successor to the `package.yml` format from the [ypkg](https://github.com/getsolus/ypkg) tool in [Solus](https://getsol.us).

For more information, please see the [packaging documentation](/docs/packaging/)

{{% /blocks/section %}}

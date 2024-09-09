---
title: Serpent OS
toc_hide: true
---

{{< blocks/cover title="Serpent OS" image_anchor="bottom" height="min" >}}
<a class="btn btn-lg btn-primary me-3 mb-4" href="/docs">
  Learn More <i class="fas fa-arrow-alt-circle-right ms-2"></i>
</a>
<a class="btn btn-lg btn-secondary me-3 mb-4" href="/download">
  Download <i class="fas fa-download ms-2 "></i>
</a>
<p class="lead mt-5">Building everyone's OS, but a little bit better.</p>
{{< blocks/link-down color="info" >}}
{{< asciinema_big id="674951" >}}

{{< /blocks/cover >}}

{{% blocks/lead color="background" %}}
Status: **Prealpha** 0.4 now [available](/blog/2024/08/01/serpent-os-prealpha0-released/)!

Given the prealpha tag, you may not yet want to use Serpent OS as your production environment of choice. That's OK. We'll get things ready around here a bit quicker, just for you.

{{% /blocks/lead %}}

{{% blocks/section type="row" color="dark" %}}
{{% blocks/feature icon="fa-arrows-rotate" title="Fearless Updates"  %}}
If an update doesn't work, it won't be applied. Thanks to atomic updates, we've got you covered. Better again, it's available instantly.
{{% /blocks/feature %}}


{{% blocks/feature icon="fas fa-hammer" title="Awesome tooling" url="/tooling" %}}
We pack a whole stack of tooling, from boot management right up to the the package manager. Packaging is easy again. And fast.
{{% /blocks/feature %}}


{{% blocks/feature icon="fas fa-screwdriver" title="Modern internals" %}}
We like new, and we like safe. The majority of our tooling is written in Rust, and we default to the LLVM toolchain for most of our packages.
{{% /blocks/feature %}}

{{% /blocks/section %}}

---
title: Serpent OS
toc_hide: true
---

{{< blocks/cover title="Serpent OS" image_anchor="bottom" height="min" color="background" >}}
<a class="btn btn-lg btn-primary me-3 mb-4" href="/about">
  Learn More <i class="fas fa-arrow-alt-circle-right ms-2"></i>
</a>
<a class="btn btn-lg btn-secondary me-3 mb-4" href="/download">
  Download <i class="fas fa-download ms-2 "></i>
</a>
<p class="lead mt-5">Redefining Linux for the modern era.</p>
<a class="btn btn-sm btn-outline-light mt-3 mb-5" href="/sponsor">
  <i class="fas fa-heart me-2"></i> Sponsor Serpent OS
</a>
{{< blocks/link-down color="info" >}}

{{< /blocks/cover >}}

{{% blocks/lead color="dark" %}}
Status: **Alpha 1** (`0.24.5`) is now [available](/blog/2024/12/23/serpent-os-enters-alpha//)!


{{% /blocks/lead %}}

{{% blocks/section type="row" color="background" %}}
{{% blocks/feature icon="fa-bolt" title="Lightning Fast Performance" %}}
Built from the ground up with performance in mind, featuring optimized compilation settings and efficient system architecture.
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-shield-alt" title="Rock-Solid Stability" %}}
Atomic updates and stateless design ensure your system remains reliable and recoverable, even after interrupted updates.
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-user-check" title="User-Friendly Experience" %}}
Modern desktop experience with sane defaults and thoughtful integration, making Linux accessible without compromising on power.
{{% /blocks/feature %}}

{{% /blocks/section %}}

{{% blocks/section color="background" %}}
<h2 class="text-center pb-3">Changing how we distribute Linux</h2>
<p class="text-center pb-4">Get live atomic updates that let you see changes immediately - our architecture doesn't require reboots just to apply updates. While certain updates like kernels will still need a reboot, we've combined proven concepts into a cohesive system where updates either fully complete or safely roll back, keeping your system running reliably.</p>
{{< asciinema id="676811" >}}
{{% /blocks/section %}}


{{% blocks/section type="row" color="background" %}}
{{% blocks/feature icon="fa-box-archive" title="moss - Package Management" url="/moss" %}}
Our atomic package manager swaps the entire /usr directory during system updates, ensuring a stateless, bulletproof upgrade process. Updates either succeed completely or not at all.
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-trowel" title="boulder - Build System" url="/boulder" %}}
Lightning-quick package building with powerful caching and a familiar YAML-based recipe format. Designed for scalability and consistent distro-wide builds.
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-hard-drive" title="blsforme - Boot Management" url="https://github.com/serpent-os/blsforme" %}}
Automated boot management that just works. Seamlessly handles your EFI System Partition and boot entries without manual intervention.
{{% /blocks/feature %}}

<div class="text-center mt-4">
<p>These are just some highlights of our tooling. <a href="/tooling">Discover our full suite of tools</a>, including the Lichen installer and more.</p>
</div>
{{% /blocks/section %}}

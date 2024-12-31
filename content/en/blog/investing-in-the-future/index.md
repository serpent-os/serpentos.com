---
title: Investing in the Future
date: 2024-12-31T14:00:11Z
authors: [ikey]
categories: [news]
---

Here we are, at the end of 2024, and what a year it's been! We've made significant progress on Serpent OS, and we're excited to share some of the highlights with you.

## Attained Alpha

Virtually 5 years in the making, we recently attained alpha status. Our tooling and concepts have aligned, allowing us to now rapidly iterate
on the core deliverable itself: Serpent OS. We've seen an explosion in cadence, with our tooling enabling us to quickly and
easily deliver updates, new packages and enabling new features.

Since the Alpha 1 ISO (`0.24.5`), we've fixed a number of issues in relation to hardware and booting. We've also added
new features to moss (refined boot management) and boulder (our build system). Even now we have multiple PRs open to
tidy up moss, add automatic generation of `monitoring.yaml` files, and more.

## Keeping the cadence

We've been working hard to keep the cadence up, and we're now at a point where we can deliver new ISOs on a regular basis.
Our main focus now is the tooling, in enabling a far more automatic delivery pipeline. The vision is having automated pull
requests generated for package updates, automatically handling changes in dependencies and ABI, and ordered by build tier.
This will significantly reduce the maintainer burden, in conjunction with planned security monitoring.

## Short term deliverables

In the short term we're going to land the following features:

- **Offline Rollbacks** - We're going to land offline rollbacks in the boot menu, allowing you to easily revert to a previous
  system state.
- **Versioned Repositories** - We're going to introduce versioned repositories, allowing us to gracefully handle format changes
  in moss and boulder, permitting an "update forever" epoch-staggering approach. Additionally, this will allow users to stay on an
  older repo version if they're awaiting a fix to a regression in a newer version.
- **Improved Documentation** - We're going to improve our documentation, making it easier for new users to get started with Serpent OS.
- **Tools as a service** - We're adding IPC layers to our tooling, allowing them to be launched as helper services for integration in
  other applications. This will allow us to integrate moss with GNOME Software and COSMIC Store, for example. Additionally it will ensure
  the latest version of the `moss` binary is always used by the system, gracefully handling version repo changes.
  Chiefly, this will allow `moss` to cheaply integrate anywhere we need it, including for `lichen`.
- **Lichen Improvements** - Lichen will also be converted to an IPC based backend, allowing it to be executed via `pkexec` for integration into
  a GUI (or even CLI) frontend. This is a necessary step to allow the frontend to operate without privileges, facilitating live
  updates to the NetworkManager configuration, or indeed keyboard layouts. Long term we're planning a `cage` based kiosk with a full screen
  installer mode, on a far smaller ISO.

## Long term vision

Our long term vision is to deliver a system that is easy to use, reliable, and secure. We're building Serpent OS to be a system that
updates forever, confidently. We're also shaking things up by being first-adopter of new technologies as default solutions, with a view
to enhancing the robustness, origin-diversity and security of the system through Rust based replacements and alternatives to key components.
You can already see this with our adoption of `sudo-rs`, `coreutils` (`uutils`), `ntpd-rs`, and not to forget `rustls` by default for our curl build.

Outside of that, `moss`, `boulder` and the supporting crates are also written in Rust, giving us a strong foundation for the future.

Serpent OS is a project that is built to last, and challenge the status quo. Deliver a Linux distribution for use on multiple verticals,
with the feeling of a conventional Linux distribution, but with key management facilities and architecture designed to make a rolling release
distribution that can be trusted for long term use, extensive updates, and the ability to entirely re-engineer the entire OS, delivering in a safe
atomic update without breaking client installations.

## How you can help

In order to give Serpent OS the development time it needs, we're looking for sponsors to help fund development. If you're interested in becoming a sponsor
or investor, please do not hesitate to get in touch. We want to secure funding for development and infrastructure for the next 2 years.

 - [Sponsors](/sponsor)
 - [Discuss sponsorship/investment](mailto:ikey@serpentos.com)

While of course we need to iterate on our own tooling, we also need to be able to work more upstream and with kindred projects to drive
the ecosystem forward. In time, we wish to become the incubator for new technologies and solutions, and we need your help to do that.

With your support, we can expand our builder network and enable more hosting, bandwidth, and compute resources. This will in turn enable
our automated rebootstraps, which will of course allow downstreams to extend upon Serpent OS as a kit-distro. Indeed, it'll allow us to expand
beyond `x86_64` when the time is right.

While Serpent OS currently delivers a desktop ISO, this is not the limit of our potential. As indicated, our priorities in the short term
are designed to massively aimplify project maintainer bandwidth and free up more time for feature iteration and development. Once we're quite
happy with the base (and we're not far from that point) - we'll quite happily extend to other desktops, and even server/cloud offerings.

Nothing is bullet proof, but with the architecture and tooling of Serpent OS we can get pretty close. Gotta admit, having a transactional, atomic OS
with rollbacks, and the full granularity of a conventional package manager, is pretty cool. 😎 Especially when things "Just work" out of the box
thanks to the stateless ("hermetic usr") requirements of the system.

Know what's even cooler? When we land our system-model implementation, you'll be able to completely duplicate the setup between local development
and production. When we also land our export/compose functionality in moss, you'll be able to reap these benefits in containers too. 🐍

Here's to a great 2025, and we hope you'll join us on this journey. 🚀

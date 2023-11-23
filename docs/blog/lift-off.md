---
title: "Lift Off"
date: 2022-12-24T01:32:04Z
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/lift-off/Featured.webp"
---

Enough of this "2 years" nonsense. We're finally ready for lift off. It is with *immense pleasure* we can
finally announce that Serpent OS has transitioned from a promise to a deliverable. Bye bye, phantomware!

### We exist

As mentioned, we spent 2 years working on tooling and process. That's .. well. Kinda dull, honestly. You're
not here for the tooling, you're here for the OS. To that end I made a decision to accelerate development of
the actual *Linux distro* - and shift development of tooling into a parallel effort.

### Infrastructure .. intelligently deferred

I deferred final enabling of the infrastructure until January to rectify the chicken/egg scenario whilst allowing
us to grow a base of contributors and an actual distro to work with. We're in a good position with minimal blockers
so no concern there.

### A real software collection

This is our term for the classical "package repository". We're using a temporary collection right now to store all
of the builds we produce. In keeping with the `Avalanche` requirements, this is the **volatile** software collection. Changes
a lot, hasn't got a release policy.

### A community.

It goes without saying, really, that our project isn't remotely possible without a **community**. I want to take the time
to personally thank everyone that stepped up to the plate lately and contributed to Serpent OS. Without the work of the
team, in which I include the contributors to our `venom` recipe repository, an ISO was never possible. Additionally contributions
to tooling has helped us make significant strides.

It should be noted we've practically folded our old "team" concept and ensured we operate across the board as a singular community,
with some members having additional responsibilities. Our belief is all in the community have equal share and say. With that said,
to the original "team", members both past and present, I thank for their (long) support and contributions to the project.

### An ISO.

We actually went ahead and created our first ISO. OK that's a lie, this is probably the 20th revision by now. And let's be brutally
honest here:

**It sucks.**

We expected no less. However, the time is definitely here for us to begin our public iteration, transitioning from suckness to a project
worth using. In order to do that, we need to get ourselves to a point whereby we can dogfood our work and build a daily driver. Our focus
right now is building out the core technology and packaging to achieve those aims.

So if you want to try our uninstallable, buggy ISO, chiefly created as a brief introduction to our package manager and toolchain, head to our
newly minted [Download](/download) page. Set your expectations low, ignore your dreams, and you will not be disappointed!

All jokes aside, it took a long time to get to point where we could even construct our first, KVM-focused, UEFI-only `snekvalidator.iso`. We now
have a baseline to improve on, a working contribution process, and a booting, self-hosting system.

The ISO is built using 2 layered collections, the `protosnek` collection containing our toolchain, and the new `volatile` collection. Much of the
packaging work has been submitted by `venom` contributors and the core team. Note you can install `neofetch` which our very own Rune Morling (`ermo`)
patched to support the Serpent OS logo.

Boot it in Qemu (or certain Intel laptops) and play with moss now! Note, this ISO is not installable, and no upgrade path exists. It is simply
the beginnings of a public iteration process.

### Next steps

In January we'll launch our infrastructure to scale out contributions as well as to permit the mass-rebuilds that need to happen. We have to
enable our `-dbginfo` packages and stripping, which were disabled due to a parallelism issue. We need to introduce our boot management based around
`systemd-boot`, provide more kernels, do hardware enabling, introduce `moss-triggers`, and much more. However, this is a **pivotal moment** for our
project as we've finally become a **real**, if not __sucky__, distro. The future is incredibly bright, and we intend to deliver on every one of our
promises.

As always, if you want to support our development, please consider [sponsoring](/sponsors) the work, or engaging with the community on Matrix or indeed
our [forums](https://forums.serpentos.com). 

You can discuss this blog post, or leave feedback on the ISO, over at our [forums](https://forums.serpentos.com/d/40-lift-off).
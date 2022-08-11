---
title: "The Shopping List"
date: 2022-08-11T00:46:07+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/the-shopping-list/Featured.webp"
---

Quick on the heels of our last blog post - its high time for us to formulate "the plan".
We'll split this up into a few sections so you know what needs to happen to proceed. Tl;DR
we need build machines and money to pull this off. **Now** is the time.

<!--more-->

# Immediate action plan

One major item we needed testing was `moss-db`, the bucket+ORM layer we built on top of
`LMDB`. Interestingly this website is powered using `moss-db`, so we kinda know it works
now =)

Here's the general "hit list" going forward:

 - Rebase `moss` on `moss-db`
 - Get `avalanche` to builds things
 - Get `summit` to control our new `snekbook` organisation on GitHub
 - Do builds
 - Add missing things to build an ISO. </>


# Next Steps

We have all the major pieces of the codebase in place, such as `moss-deps` for dependency
management and analysis, `moss-db` for database abstraction, `moss-fetcher` for parallel
downloads, etc.

`avalanche` is the easiest piece to implement:

 - Use `vibe.d` to listen on control port
 - Accept build messages (REST) from `summit` (auth'd with JWT)
 - Clone the payloads ref
 - Build it
 - Report status along with public URI to download assets

When `summit` is informed of a successful build, it instructs `vessel` (the repo manager)
to go and incorporate those assets, and then we can finally update the job status on the
dashboard.

The repository manager is another simple `vibe.d` application which uses auth'd REST APIs,
along with `moss-format` for reading/writing moss files, and `moss-db` for persistence.
Everything else is simply putting files in the right places and spitting out an index file
for clients.

So with all that tooling coming to a point of early <abbr title="Proof of concept">PoC</abbr> fruition, what do we need?

# What We Need

Here it is, the shopping list for success :)

## Web servers

Our main website is living on an AWS node right now, which isn't sustainable. We need somewhere else
for this to live, along with the `Summit` dashboard.

The plan is to use our kindly provided [Fosshost](https://fosshost.org) system for the repository, enabling
integration with the mirror network.

## Build servers

We do have access to partial-uptime systems in our developer network, but we don't have any statically configured
"beefy servers" to enable builds.

At minimum, we'll need modern always-up x86-64 (`v3` + `v2`) build machines. To enble AArch64 down the road we
will also need dedicated build machines and a test system such as the Pinebook.

For a quick bring up we realistically need **two** `x86_64` build systems. They don't need boatloads of disk space,
enough for 25-30GB build trees and 32GB RAM minimum. This is likely going to be quite costly each month, so sponsor-
provided hardware will be the most sustainable option. Cloud VPS with janky static kernels won't cut it.

## Income

This one sounds stupid, doesn't it? Guy trying to bring up a project asking for income before its out. I feel dumb
asking too. I'm pouring my heart, soul and experience into building this as I **know** it's not only going to be
successful, but highly disruptive. Most of us in the community are just trying to settle on something innovative
that **works** without breaking the classic reasons to use Linux.

I'm incredibly close to getting us there. We have all the modules, its now a case of tying it all together into
a cohesive *whole*. We've taken the long route to ensure we'll have the tooling to scale when we kick off, I now
need **your help** to make us scale **now**.

# And when you have all that..?

Spit out ISOs. With our tooling we'll be able to rapidly go from no-repos to fully fledged test ISOs with a
desktop environment. We'll flesh the tooling out as we go along for triggers and boot management to facilitate
installs and then its a case of stabilising/fleshing everything out in line with our vision.

Without further ado..

## I'm a community member, how do I help?

Sign up on our [forums](https://forums.serpentos.com) and get ready to enter into a test-feedback cycle.
Visit our [OpenCollective](https://opencollective.com/serpent-os) now to beef out the project income for
both myself and the admin fees for everything. The community is the heart and soul of Serpent OS, we need
**you** to build the foundations for a fledgling project that will provide a technological home for many years
to come.

If OpenCollective doesn't as an option, we're in the process of setting up Stripe, and there is the possibility
of direct bank transfer (EUR). Just send me an [email :)](mailto:ikey@serpentos.com)

## I represent an organisation and I want to ensure the success of Serpent OS

Shoot me an [email now](mailto:ikey@serpentos.com) from your company email address. We're willing to work
out mutual advertising partnerships that don't compromise the project in any way. Long story short, your
organisation will forever be entwined in the success story of Serpent OS, a highly disruptive project offering
something genuinely **new** to the world of Arch Linux and Fedora users, among other groups.

Let's do this guys. We're on the cusp.
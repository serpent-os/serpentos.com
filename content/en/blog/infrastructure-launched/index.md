---
title: "Infrastructure Launched!"
date: 2023-03-18T23:20:55+00:00
draft: false
authors: [ikey]
categories: [news]
---

After many months and much work, our infrastructure is [finally online](https://dash.serpentos.com).
We've had a few restarts, but it's now running fully online with 2 builders, ready to serve builds
around the clock.

<!--more-->

Firstly, I'd like to apologise for the delay since our last blog post. We made the decision to move
this website to static content, which took longer than expected. We're still using our own D codebase,
but prebuilding the site (and fake "API") so we can lower the load on our web server.

### Introducing the Infra

Our infrastructure is composed of 3 main components.

#### Summit

This is the page you can see over at [dash.serpentos.com](https://dash.serpentos.com). It contains
the build scheduler. It monitors our git repositories, and as soon as it discovers any missing builds
it creates build tasks for them. It uses a graph to ensure parallel builds happen as much as possible,
and correctly orders (and blocks) builds based on build dependencies.

#### Avalanche

We have 2 instances of Avalanche, our builder tool, running. This accepts configuration + build requests
from Summit, reporting status and available builds.

#### Vessel

This is an internal repository manager, which accepts completed packages from an Avalanche instance.
Published packages land at [dev.serpentos.com](https://dev.serpentos.com)

### Next steps

Super early days with the infra but we now have builds flowing as part of our continuous delivery solution.
Keeping this blog post short and sweet... we're about to package GNOME and start racing towards our first
**real** ISOs!

### Don't forget

If you like what the project is doing, don't forget to [sponsor](https://github.com/sponsors/ikeycode?o=sd&sc=t)!

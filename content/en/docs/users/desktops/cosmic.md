+++
title = 'COSMIC'
date = 2024-09-10T00:07:10Z
description = "COSMIC Desktop"
weight = 10
+++

The [COSMIC Desktop](https://system76.com/cosmic) from [System76](https://system76.org) is a highly popular
choice with Serpent OS users. Despite early alpha status, it is notable for being written in Rust and using
a modern multiprocess architecture, while being Wayland-only. For many, this makes Serpent OS and COSMIC an
ideal partnership.

{{< alert color="secondary" >}}
As of prealpha `0.4`, it is possible to install the COSMIC desktop directly at installation time using the
desktop selection list in `lichen`, our system installer.
{{< /alert >}}

### Installing COSMIC on Serpent OS

```bash
sudo moss install cosmic-desktop
```

### Controlling the display manager

If you've installed COSMIC over the top of a GNOME install, you can safely remove `gdm` and have
`cosmic-greeter` take over. Note: GNOME Shell still expects `gdm` for full functionality.
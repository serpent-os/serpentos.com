+++
title = 'cargo'
date = 2024-09-10T00:38:41Z
description = "Rust project builds"
weight = 20
+++

When building "pure" [Rust](https://rust-lang.org) packages with the `cargo` build tool, ensure you use
the `%cargo*` macros to allow `boulder` to control the various tuning options and debuginfo behaviour.

{{% render_macro_actions "cargo" %}}

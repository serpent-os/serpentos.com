#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2020-2022 Serpent OS Developers
#
# SPDX-License-Identifier: Zlib
#
# Build 'website' binary for deployment in production w/optional flags
#
set -e
set -x

# remove everything not tracked by git and reset to origin
git clean -dfx && git reset --hard HEAD
# Notes re. GC magic here: https://forum.dlang.org/post/befrzndhowlwnvlqcoxx@forum.dlang.org
DFLAGS="--flto=thin -O3 --static --DRT-gcopt=heapSizeFactor:0.25" dub build -b release --parallel ${*}
strip website

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
DFLAGS="--flto=thin -O3 --static" dub build -b release --parallel ${*}
strip website

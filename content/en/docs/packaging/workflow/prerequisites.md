+++
title = 'Prerequisites'
date = 2025-01-01T18:28:22+01:00
weight = 10
description = "Prerequisites for building packages on Serpent OS"
+++

To set up a Serpent OS system to be able to build package recipes, a few prerequisites need to be
installed, and a new directory for storing local build artefacts needs to be set up.

## Installing the `build-essential` package

We maintain a `build-essential` metapackage that should contain the basics for getting started
with packaging on Serpent OS.

```bash
sudo moss sync -u
sudo moss it build-essential
```

## Activating the Serpent OS helper scripts

The easiest way to create a local repository is to use the helper script distributed with the
Serpent OS recipe repository in the `tools/` directory.

Start by cloning the recipes/ git repository:

```bash
mkdir -pv repos/serpent-os/
pushd repos/serpent-os
git clone https://github.com/serpent-os/recipes

```

After the recipes/ git repositori has been cloned, symlink helpers.bash into `~/.bashrcd.d/`:

```bash
popd
mkdir -pv ~/.bashrc.d/
ln -sv ~/repos/serpent-os/recipes/tools/helpers.bash ~/.bashrc.d/90-serpent-helpers.bash
```

Finally, execute the following in a new a new terminal tab:

```bash
cd ~
gotoserpentroot
```

If the helpers script has been correctly loaded, the `gotoserpentroot` command should switch to
the directory containing the recipes/ git repository clone.


## Adding /etc/subuid and /etc/subgid entries

Since `boulder` uses user-namespaces to set up isolated build roots, it is necessary to set up
a subuid and a subgid file for the relevant users first:

```bash
sudo touch /etc/sub{uid,gid}
sudo usermod --add-subuids 1000000-1065535 --add-subgids 1000000-1065535 root
sudo usermod --add-subuids 1065536-1131071 --add-subgids 1065536-1131071 "$USER"
```

If `/etc/subuid` and `/etc/subgid` already exist, adapt the above as appropriate.

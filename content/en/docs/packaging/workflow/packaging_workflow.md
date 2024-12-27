+++
title = 'Packaging Workflow'
date = 2024-12-27T16:25:00Z
weight = 10
description = "Building and testing `stone.yaml` recipe build artifacts"
+++


Before the system can build recipes, a few prerequisites need to be installed and a new directory 
for storing local build artefacts needs to be set up.

## Installing `build-essentials`

We maintain a `build-essentials` metapackage that should contain the basics for getting started
with packaging on Serpent OS.

```bash
sudo moss sync -u
sudo moss it build-essentials
```

## Activating the Serpent OS helper scripts

The easiest way to create a local repository is to use the helper script distributed with the
Serpent OS recipe repository in the `tools/` directory.

```bash
mkdir -pv repos/serpent-os/
pushd repos/serpent-os
git clone https://github.com/serpent-os/recipes
popd
ln -sv ~/repos/serpent-os/recipes/tools/helpers.sh ~/.bashrc.d/90-serpent-helpers.sh
```


## Adding /etc/subuid and /etc/subgid entries

Since `boulder` uses user-namespaces to set up isolated build roots, it is necessary to set this up
first:

$ sudo touch /etc/sub{uid,gid}
$ sudo usermod --add-subuids 1000000-1065535 --add-subgids 1000000-1065535 root
$ sudo usermod --add-subuids 1065536-1131071 --add-subgids 1065536-1131071 "$USER"


## Understanding moss-format repositories

When building and testing packages locally, boulder (and moss) can be configured to consult a local
moss-format repository containing `.stone` build artifacts and a `stone.index` local repository
index.

### `stone.index` files

The `stone.index` file is what both moss and boulder consult when they check which packages are
available to be installed into moss-maintained system roots.

Adding a moss-format repository is as simple as registering a new location from where to fetch
`stone.index` files.

### `moss` build roots

Every time a package is built, `boulder` calls out to `moss` to have it construct a pristine build root
directory with the necessary package build prerequisites installed.

The packages in this build root are resolved from one or more moss `stone.index` files, sorted in
descending priority, such that the highest priority repository "wins" when package providers are
resolved.

The lowest priority repository will typically be the official Serpent OS upstream package
repository.

If higher priority repositories are added, packages from these will in turn override the packages
available in the official Serpent OS upstream package repository.

The next section deals with how to create and register a higher priority local moss-format
repository, which is colloquially referred to as a "local repo".


## Creating a local repository

After the helper script has been activated in `bash`, open a new tab or a new terminal, and execute
the following commands:

```bash
# create a new tab or open a new terminal
gotoserpentroot
just create-local
just index-local
```

The `just create-local` invocation will set up an empty `~/.cache/local_repo/x86_64/` directory,
and the `just index-local` invocation will create a `stone.index` file for the directory.


### Making boulder use the local repository

Boulder will need to have its list of "build profiles" be updated before it will consult the
`~/.cache/local_repo/x86_64/stone.index` moss-format repository index created above:

```bash
boulder profile list
boulder profile add --repo name=volatile,uri=https://packages.serpentos.com/volatile/x86_64/stone.index,priority=0 local-x86_64
boulder profile update --repo name=local,uri=file://${HOME}/.cache/local_repo/x86_64/stone.index,priority=100 local-x86_64
boulder profile list
```


### Enabling `moss` to install local repository packages

Boulder builds from the `volatile` repository, hence it is wise to set it up as being disabled by
default:

```bash
moss repo list
moss repo add volatile https://packages.serpentos.com/volatile/x86_64/stone.index -p 10
moss repo disable volatile 
moss repo add local file://${HOME}/.cache/local_repo/x86_64/stone.index -p 100
moss repo disable local
moss repo list
```

In the above priority tower, moss-format packages would first get resolved via the `local`
repository (priority 100), then from the `volatile` repository (priority 10), and finally from the
`unstable` repository (priority 0), the latter of which is the official upstream Serpent OS
moss-format `.stone` package repository.

Users of Serpent OS should generally _not_ have the `volatile` repository be enabled, because this
repository is where new `.stone` packages land right after being built, which means the repository
can potentially be in an undefined and volatile state when building large build queues (hence the
name).

However, when testing locally built packages, they _must_ be built against the `local-x86_64` boulder
build profile, which in turns relies on the `volatile` repostiory via the boulder `local-x86_64`
build profile.

Hence, when testing locally built packages, you may need to _**temporarily**_ enable the `volatile`
repository for moss to resolve from.

## Building recipes using the `local-x86_64` profile

To actually build a recipe, it is recommended that new packagers start out by building `nano`.

```bash
# Go into the root of the serpent recipe directory 
gotoserpentroot
# change to the directory holding the nano recipe
chpkg nano
# bump the release number in the nano recipe
just bump
# build the bumped nano recipe
just build
# move the build artifacts to the local repository
just mv-local
# list the build artifacts in the local repository
just ls-local
```

Note that the basic packaging workflow in Serpent OS assumes that you are using a local repository.

If you are building multiple package recipes, you will need to `just build` and `just mv-local`
for each package recipe sequentially.


## Updating the installed system state

Testing your package(s) is now as simple as:

- Enabling (or disabling) the relevant moss-format repositories with:
  `sudo moss repo enable/disable <the repository>`
- Updating moss' view of the enabled moss-format repository indices with:
  `sudo moss sync -u`


## Cleaning the local repository

Often, it will be prudent to clean out the local repository after the associated recipe PR has been
accepted upstream.

```bash
gotoserpentroot
just clean-local
sudo moss repo disable volatile
sudo moss repo disable local
sudo moss sync -u 
```

This will sync the the local system to a new installed system state made only from the upstream
`unstable` moss-format `.stone` package repository state.

This will effectively make the new system state "forget" the nano version installed from the local
repository in the previous system state.

## Ending notes

If you have made it this far, congratulations! You should know understand the basic workflow of
packaging and managing repositories with Serpent OS.

Tip: execute `just -l` to see a list of supported `just` 'recipes', which are common actions that
     have been automated by the Serpent OS developers.

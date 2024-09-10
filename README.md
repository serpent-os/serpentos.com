serpentos.com
--------------

This repository hosts the [hugo](https://gohugo.io) based website of [Serpent OS](https://serpentos.com)

We make use of [docsy](https://docsy.dev) for the theme.

## Building

Assuming `hugo` is in your path, you'll need to get `postcss-cli` available:

```bash
npm i
```

Now run the live server for testing:

```bash
PATH=$(pwd)/node_modules/bin:${PATH} hugo server --disableFastRender
```

## Generating new pages

By and large contributors will be changing the documentation. The root of the tree is considered to be `content/en`, and
is already understood by the hugo configuration.

To create a new documentation page in `content/en/docs/packaging`, we'd do:

```bash
hugo new content docs/packaging/my_new_file.md
```

## Updating documentation (`content/en/docs`)

Note that the boulder macro docs are automatically generated from the `boulder/data/macros` files in the [moss](https://github.com/serpent-os/moss) repository.

Currently we manually copy the files across but a more dynamic approach will be used soon.

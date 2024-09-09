+++
title = 'Overview'
date = 2024-09-08T00:15:31Z
description = "Stateless management of Serpent OS user accounts"
weight = 10
+++

As a stateless distribution, Serpent OS does not permit the modification of `/etc/passwd` and co by
packages or triggers. Instead, we integrate `nss-systemd` and `userdb`.

{{% alert color="danger" %}}

The use of `nss` means that user accounts and groups defined by this mechanism are only available
to packages using the correct `glibc` APIs. Statically linking with `musl` or directly reading
`/etc/passwd`, `/etc/group`, etc, will not reveal these accounts.

{{% /alert %}}

The main benefit with this approach is ensuring that we do not directly mutate system files, and that
unlike the `sysusers` mechanism, removal of a package ensures these system user and group definitions
are no longer available.

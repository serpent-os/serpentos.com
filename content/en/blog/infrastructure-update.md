---
title: "Infrastructure Update"
date: 2022-07-10T11:26:05+01:00
draft: false
authors: [ikey]
categories: [news]

---

Since the last post, I've pivoted to full time work on Serpent OS, which is
made all the more possible thanks to everyone supporting us via [OpenCollective](https://opencollective.com/serpent-os) <3.

We've been working towards establishing an online infrastructure to support the automation of package **builds**, while
revisiting some core components.

<!--more-->

# moss-db

During the development of the Serpent OS tooling we've been exploring the possibilities of D Lang, picking up new
practices and refining our approach as we go. Naturally, some of our older modules are somewhat ... _smelly_.
Most noticeable is our `moss-db` module, which was initially intended as a lightweight wrapper around [RocksDB](http://rocksdb.org/).

In practice that required an encapsulation API written in D around the C API, and our own wrapping on top of that. Naturally,
it resulted in a very allocation-heavy implementation that just didn't sit right with us, and due to the absurd complexity
of RocksDB was still missing quite a few features.

## Enter LMDB

We're now using the [Lightning Memory-Mapped Database](https://www.symas.com/lmdb) as the driver implementation
for moss-db. In short, we get rapid reads, ACID transactions, bulk inserts, you name it. Our implementation takes
advantage of multiple database indexes (`MDB_dbi`) in LMDB to partition the database into internal components,
so that we can provide "buckets", or collections. These internal DBs are used for bucket mapping to permit a
key-compaction strategy - iteration of top level buckets and key-value pairs within a bucket.

## Hat tip, boltdb

The majority of the API was designed with the [boltdb](https://github.com/boltdb/bolt) API in mind. Additionally
it was built with `-preview=dip1000` and `-preview=in` enabled, ensuring safely scoped memory use and no
room for memory lifetime issues. While we prefer the use of generics, the API is built with `immutable(ubyte[]`)
as the internal key and value type.

Custom types can simply implement `mossEncode` or `mossDecode` to be instantly serialisable into the database
as keys, values or bucket identifiers.

Example API usage:

```d
Database db;
/* setup the DB with lmdb:// URI */

/* Write transaction */
auto err = db.update((scope tx) @safe
{
    auto bucket = tx.bucket("letters");
    return tx.set(bucket, "a", 1);
});

/* do something with the error */

err = db.view((in tx) @safe
{
    foreach (name, bucket ; tx.buckets!int)
    {
        foreach (key, value ; tx.iterator!(string,string)(bucket))
        {
            /* do something with the key value pairs, decoded as strings */
        }
    }

    /* WILL NOT COMPILE. tx is const scope ref :) */
    tx.removeBucket("numbers");

    return NoDatabaseError;
}
```

## Next for moss

Moss will be ported to the new DB API and we'll gather some performance metrics,
while implementing features like expired state garbage collection (disk cleanup),
searching for names/descriptions, etc.

# Avalanche

![Early version of avalanche, in development](../../static/img/blog/infrastructure-update/Featured.webp)

Avalanche is a core component of our upcoming infrastructure, providing the
service for running builds on a local node, and a controller to coordinate
a group of builders.

Summit will be the publicly accessible project dashboard, and will be responsible
for coordinating incoming builds to Avalanche controllers and repositories.
Developers will submit builds to Summit and have them dispatched correctly.

So far we have the core service process in place for the Controller + Node,
and now we're working on persistence and handshake. TLDR; fancy use of
moss-db and JSON Web tokens over mandated SSL. This means our build infra
will be scalable from day 1 allowing multiple builders to be online very
early on.

# Timescale

We're planning to get an early version of our infrastructure up and running
within the next 2 weeks, and get builds flowing =)

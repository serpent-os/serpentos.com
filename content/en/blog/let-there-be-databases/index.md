---
title: "Let There Be Databases"
date: 2021-05-18T10:31:32+01:00
draft: false
authors: [ikey]
categories: [news]
---

We haven't been too great on sharing progress lately, so welcome to an overdue update on
timelines, progress, and database related shmexiness.

<!--more-->

![Emerging DB design](../../static/img/blog/let-there-be-databases/Featured.webp)


OK, so you may remember `moss-format`, our module for reading and writing moss binary archives.
It naturally contains much in the way of binary serialisation support, so we've extended the
format to support "database" files. In reality, they are more like tables binary encoded into
a single file, identified by a filepath.

The DB archives are currently stored **without** compression to ensure 0-copy mmap() access
when loading from disk, as a premature optimisation. This may change in future if we find the
DB files taking up too much disk space.

So far we've implemented a "StateMetaDB", which stores metadata on every recorded State on
the system, and right now I'm in the progress of implementing the "StateEntriesDB", which is
something akin to a binary encoded dpkg selections file with candidate specification reasons.

Next on the list is the LayoutsDB (file manifests) and the CacheDB, for recording refcounts
of every cached file in the OS pool.

# Integration with Serpent ECS

An interesting trial we're currently implementing is to hook the DB implementation up to
our Entity Component system from the Serpent Engine, in order to provide fast, cache coherent,
in memory storage for the DB. It's implemented using many nice DLang idioms, allowing the full
use of `std.algorithm` APIs:

```d

    auto states()
    {
        import std.algorithm : map;

        auto view = View!ReadOnly(entityManager);
        return view.withComponents!StateMetaArchetype
            .map!((t) => StateDescriptor(t[1].id, t[3].name, t[4].description,
                    t[1].type, t[2].timestamp));
    }
    ...

	/* Write the DB back in ascending numerical order */
	db.states
		.array
		.sort!((a, b) => a.id < b.id)
		.each!((s) => writeOne(s));
```

# Tying it all together

Ok, so you can see we need basic DB types for storing the files for each moss archive, plus each
cache and state entry. If you look at the ECS code above, it becomes quite easy to imagine how this
will impact installation of archives. Our new install code will simply modify the existing state,
cache the incoming package, and apply the layout from the DB to disk, before committing the new
DB state.

In essence, our DB work is the current complex target, and installation is a <50 line trick
tying it all together.

```d
	/* Psuedocode */

	State newState...

	foreach (pkgID; currentState.filter!((s) => s.reason == SelectionReason.Explicit))
	{
		auto fileSet = layoutDB.get(pkgID);
		fileSet.array.sort!((a, b) => a.path < b.path).each!((f) => applyLayout(f));
		/* Record into new state */
		...
	}

```

Til next time -

 Ikey

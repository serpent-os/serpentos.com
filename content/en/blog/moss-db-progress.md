---
title: "Moss DB Progress"
date: 2021-08-03T14:16:16+01:00
draft: false
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/moss-db-progress/Featured.webp"
---

I'll try to make this update as brief as I can but it's certainly an important one, so
let's dive right into it. The last few weeks have been rough but work on our package manager
has still been happening. Today we're happy to reveal another element of the equation: moss-db.

<!--more-->

{{<figure_screenshot_one image="moss-db-progress/Featured" caption="Putting moss-db to the test">}}

`moss-db` is an abstract API providing access to simplistic "Key Value" stores. We had initially used
some payload based files as databases but that introduced various hurdles, so we decided to take
a more abstract approach to not tie ourselves to any specific implementation of a database.

Our main goal with `moss-db` is to encapsulate the [RocksDB](https://rocksdb.org/) library, providing sane, idiomatic access
to a key value store.

# High level requirements

At the highest level, we needed something that could store arbitrary keys and values, grouped
by some kind of common key (commonly known as "buckets"). We've succeeded in that abstraction,
which also required us to fork a `rocksdb-binding` to add the `Transform` APIs required.

Additionally we required idiomatic range behaviours for iteration, as well as generic access
patterns. To that affect we can now `foreach` a bucket, pipe it through the awesomely powerful
`std.algorithm` APIs, and automatically encode/decode keys and values through our generic APIs
when implementing the `mossdbEncode()` and `mossdbDecode()` functions for a specific **type**.

In a nutshell, this was the old, ugly, hard way:


```d
	/* old, hard way */
	auto nameZ = name.toStringz();
	int age = 100;
	ubyte[int.sizeof] ageEncoded = nativeToBigEndian(ageEncoded);
	db.setDatum(cast(ubyte[]) (nameZ[0 .. strlen(nameZ)]), ageEncoded);
```

And this is the new, shmexy way:

```d
    db.set("john", 100);
    db.set("user 100", "bobby is my name");

    auto result = db.get!int("john");
    if (result.found)
    {
        writeln(result.value);
    }

    auto result2 = db.get!string("user 100");
    if (result2.found)
    {
        writeln(result2.value);
    }
```

It's quite easy to see the new API lends itself robustly to our needs, so that
we may implement stateful, strongly typed databases for moss.

# Next Steps

Even though some APIs in `moss-db` may still be lacking (remove, for example)
we're happy that it can provide the foundation for our next steps. We now need
to roll out the new `StateDB`, `MetaDB` and `LayoutDB`, to record system states,
package metadata, and filesystem layout information, respectively.

With those 3 basic requirements in place we can combine the respective works
into installation routines. Which, clearly, warrants another blog post ... :)

For now you can see the relevant projects on our [GitLab](https://gitlab.com/serpent-os/core) project.

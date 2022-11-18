---
title: "Let There Be Databases"
date: 2021-05-18T10:31:32+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/let-there-be-databases/Featured.png"
---

We haven't been too great on sharing progress lately, so welcome to an overdue update on
timelines, progress, and database related shmexiness.

<!--more-->

# Quick word on personal circumstances


The last year, as many likely know by now, has been an incredibly stressful one. I'm not
talking about the pandemic, although that obviously hasn't helped. In fact, for the
majority of the past 3 years, my family and I have been in a constant vicious cycle
in attaining true stability.

You see, we're Irish Travellers. Having a home that is culturally appropriate, safe,
and conducive to our family success has been a long struggle. Without getting bogged
down in the politics of it all, the system is rigged against us, making our lives a
daily struggle against discrimination.

..But you didn't click onto this blogpost for a sob story. Suffice to say, a unique
stepping-stone opportunity emerged for us which required a radical shift in our own
approach. As such we've secured a "plot", on which we can place a mobile home ("static
caravan"). To enable this transition to a more stable, discrimination-free life, we've
liquidated pretty much **everything**, including our own trailer ("caravan").

The interim period has required us to stay in holiday camps while we await the delivery
of our mobile home. On the 28th of this month, we return to the plot where we'll
get the home ready, including plumbing, electrics, furnishings, etc. A plan is in place
to ensure this happens rapidly, with the return of a stable home and work environment
anticipated within the first days of June.

As I've said before, it's been a long, multiyear battle, but finally having somewhere
to call home that is safe for ourselves and our children, whilst respecting our culture
rather than trying to stamp it out, is an extraordinary milestone for us. As such that
stability will project through in all aspects of our lives, most importantly for you:
my development work.

I'm hopeful that this honest blog section will make it easier for people to grok what
we've been going through (add upcoming baby #4, a few skirmishes with COVID19, etc) and
the high level of commitment I personally have for Serpent OS and Lispy Snake projects.

Every change in our lives right now is designed around longevity and stability, and the
fruits of those labours will manifest in less than 2 weeks. Please note this is not some
sad attempt at a "bleeding heart, fill me coffers" kind of post, it's more addressing the
growing unrest at slow development, whilst allowing me to be fully honest with the community
and not having to hide my cultural identity, as I have done so for too many years within
the industry.

Over the past few years I've found it utterly depressing that I've had to suppress my
cultural and ethnic identity in the fear that it might upset others or make me a target
(and has done, on many occasions). As my family and I are making a fresh start, it is
high time that freshness and honesty was mirrored to my work. So, with a very happy heart,
I'll be investing that freedom and energy into all my projects :)

# Sweetness. Tell me bout them databases

{{<figure_screenshot_one image="let-there-be-databases/Featured" caption="Emerging DB design">}}


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

{{<highlight d>}}

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
{{</highlight>}}

# Tying it all together

Ok, so you can see we need basic DB types for storing the files for each moss archive, plus each
cache and state entry. If you look at the ECS code above, it becomes quite easy to imagine how this
will impact installation of archives. Our new install code will simply modify the existing state,
cache the incoming package, and apply the layout from the DB to disk, before committing the new
DB state.

In essence, our DB work is the current complex target, and installation is a <50 line trick
tying it all together.

{{<highlight d>}}

	/* Psuedocode */
	
	State newState...

	foreach (pkgID; currentState.filter!((s) => s.reason == SelectionReason.Explicit))
	{
		auto fileSet = layoutDB.get(pkgID);
		fileSet.array.sort!((a, b) => a.path < b.path).each!((f) => applyLayout(f));
		/* Record into new state */
		...
	}

{{</highlight>}}

I know we've gone the long way around creating the package manager, and many times there have
been delays over the past year. However, we're no longer looking at light at the end of the
tunnel, we're actively walking out of it. The remaining minor puzzles will unblock the
installation routine, which in time will enable first alpha images of dubiuous quality.
However rough our jumping off point, it will be an awesome journey.

Til next time - 

 Ikey

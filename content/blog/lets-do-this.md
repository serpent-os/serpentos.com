---
title: "Let's Do This"
date: 2022-08-08T15:08:21+01:00
draft: false
type: "post"
authors: [ikey]
categories: [news]
featuredImage: "/img/blog/lets-do-this/Featured.webp"
---

It's high time we had a project relaunch. What better way to do that than with a brand new website?
Alright I'll admit it's been a while since our last blogpost, so let's jump right into it then.

<!--more-->

We're at a point now where we'd like to go *live*.

I repeat.

<h1 class="display-6 text-center">Go Live</h1>

So, to enable that, we're bringing up all the services required to support such a move. We got the
new website, forums, fixing up email, and putting the last touches on the build infrastructure to get
this boat moving.

# New website

Since the project began we've been chopping away at a Hugo based website. Over time it has become an
absolute nightmare to maintain, and has fallen by the wayside. Plus, it's absolutely <del>hideous</del> ungorgeous.

First thing to note, we've implemented the new website with a [D Lang](https://dlang.org) backend using the [vibe.d](https://vibed.org) framework.
The frontend is implemented using a mixture of static templates and JavaScript rendering from a REST backend. This is
what powers the new paginated [blog listing](/blog).

## Static. Kinda

The new website is **kinda** static but also not. For now our <abbr title="Proof Of Concept">POC</abbr> simply loads all of
the old content from the Hugo markdown files, and bakes them ahead-of-time into an [LMDB](https://www.symas.com/lmdb) powered database
Then at runtime, we simply load the contents from the database and merge into a template.

```d
writeln("Also, we're using Chroma for syntax highlighting, baked ahead of time");
```

## Faster. Much Faster.

Despite the old website being **entirely** static, loading all those files was ironically slow. The main web server now uses
nginx and proxies requests to the `website` application, which in turn has most content accessible via `mmap` thanks to LMDB.
Additionally we've got proper caching policies, an improved stylesheet thanks to [tabler](https://tabler.io), and dropped all
the huge PNGs in the site in favour for `.webp` - resulting in significantly faster page load times.


# Forums

We're still in the process of it but we got ourselves some brand new shiny forums! Due to an email host
issue we're manually activating accounts, though you can login with GitHub OAuth and sidestep the issue.
Please do join in and meet the community, we're very excited to have you =)

![Forums](/static/img/blog/lets-do-this/forums.webp)

# To GitHub! (Again)

It hasn't quite happened just yet, but we're in the process of moving back to GitHub. I know some may question
this in terms of the openness of the platform, etc. In order for our build workflow to actually.. work, we need
organisation-wide access tokens - which is something that GitLab offers for SaaS and self-hosted enterprise licenses.

GitHub, on the other hand, has a very well documented GitHub Apps API and will allow us to implement our dashboard
in a way that permissions, team roles and repositories can be controlled and synced to automate our workflow.

# Next steps

Apart from some bugs in this website that will need resolving, all focus is on the build infrastructure. Once deployed
we'll have a rolling pipeline for package builds and an open infrastructure to permit collaboration on our packaging
and updates. From there it's a race towards our first goals of getting everyone on Serpent OS installs for testing!

# Lastly...

I know the world isn't making things easier right now for any of us, so from the bottom of my heart I want to thank
everyone who has been supporting the project, it means the absolute world to me. We're now in a position of community
building and developer enabling, a position we've fought the last 2 years to get to. Thanks to you all, we're hitting the
launch button and going hypersonic.

You can leave feedback on this blog post over [on the forums](https://forums.serpentos.com/d/7-lets-do-this)
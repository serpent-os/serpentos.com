---
title: "A Smooth Experience For All Levels"
date: 2022-01-12T11:46:12+11:00
draft: false
Callout: "Empowering users to make their own decisions, without getting in their way"
---

<!---
Why:
- Users have different needs and use cases
- Users enjoy tweaking different parts of the system
- Want their device to adapt to them, not the other way around

How:
- Tools to Meet Your Needs
- Community Maintained Source Repository
- Not Quite a Free Lunch (reliability declines with more choices)
--->

An Operating System is a tool to help get things done and shouldn't feel like a frustration. Users have varying needs
and use cases and enjoy different levels of customization. Serpent OS adapts to your level with providing a sane and
fast experience out of the box, while providing the tools to easily modify your install for those who enjoy tinkering.

Whether you want to just get things done or get stuck in behind the scenes, Serpent OS is a compelling choice for both
use cases, and anywhere in-between.

# Tools to Meet Your Needs

Serpent OS is highly extensible, allowing you to create use cases we never dreamed of! Our much more than a package
manager `moss` grants you flexibility in how you want to setup your computer. This gives you options to get your
software from a variety of sources, including building your own packages. With all of our tools accessible to everyone,
it's really down to you how far you want to go.

# Community Maintained Source Repository

Serpent OS allows users to easily build and package software that may not be available in the main repository yet. By
providing easy access to a shared community repository, users can share their work to conveniently allow others to
install extra software on their devices. This creates an easy path for new contributors to get their feet wet and move
their contributions upstream to add pre-compiled binaries. A real win-win for users, greater access to software and a
place to gain packaging experience before contributing to the main repository!

To enable the best experience, tooling enforces a few requirements to ensure built software is of a higher quality.

- Linting of builds that can fail if doing something wrong with feedback
- Validation that the build fragments match the actual completed build (and not hand edited)
- Quick review of commits prior to merging (for contributors without access yet)
- Not conflicting with files from the core repository (with potential exceptions like wine branches or mesa)

You can even rebuild packages targeted specifically for your CPU for those packages that are important to you. We will
also add more pre-built packages for newer CPUs so that you probably won't want to anymore.

# Not Quite a Free Lunch

While flexibility provides many benefits, it can come with a reduction in reliability. Community reviews of updates are
to ensure correctness of the build and not the quality or stability of the software contained. We take steps with our
tooling so that you can try and extend your system, but fallback to a previous working state if things go wrong. So
sticking to software that is well known will always be recommended for maximum reliability.

The community repository will be separated from the Serpent OS main repository so that the team cannot prevent packages
being added that they may not see value in. That means it's up to you to make the right choices for the software you
install on your system. You can choose to only use the main Serpent repository and be assured of well tested and
supported software.

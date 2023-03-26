Develop a prototype version of Serpent OS that will inform design decisions
on the infrastructure and tooling viability as built in the first stage.

Our deliverable for this stage will be an alpha quality ISO capable of running
under typical virtualisation solutions as well as on a very limited set of hardware
configurations (for example, most will not get functioning WiFi!)
During this stage we'll focus largely on the maintainer experience for delivering
packages via our infrastructure, and begin to fill in the missing pieces, primarily:

 - Begin integration of a stateless policy
 - Implement first version of package installation triggers
 - Rearchitect `moss` and `boulder` to be fully asynchronous
 - Support package updates and persistent install roots.

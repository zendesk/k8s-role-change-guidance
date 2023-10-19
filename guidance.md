# Guidance on how to handle added / removed Kubernetes roles

This PR adds or removes Kubernetes roles.

Due to the way that we currently configure our Spinnaker pipelines,
pull requests which add and/or remove Kubernetes roles require special handling;
in short, because they cannot be rolled back.

Please read the following guidance on how to merge and deploy this PR safely.

## How to merge and deploy this PR safely

* Wait until you're ready to merge.
* Call a "hold merges" on all pull requests for this repository.
  * If you can, enforce this by changing the repository's branch protection settings.
* If there are any in-progress deployments, wait for them to complete.
* If there are any not-yet-deployed tags, wait for them to be deployed.
* **Only once there are no in-progress deployments, AND no undeployed tags**, merge this pull request.
* Deploy the release that the merge created.
* Wait for that deployment to complete.
* Lift the "hold merges".
  * If the branch protection settings were changed earlier, then change them back.

## Minimizing risk

Because of these requirements it's a good idea to **change as little as possible**
in pull requests which add / remove Kubernetes roles, other than the role addition / removal itself.

To add a new role, with some implementation code:

- **make and merge and deploy** a pull request to add the new role (with zero replicas, and no code behind it);
- make and merge and deploy a pull request to add implementation code, and set the replicas to the desired value.

To remove a role, and clear up its implementation code, do the reverse:
 
  - **make and merge and deploy** a pull request to remove the implementation code, and set the role's replicas to zero;
  - make and merge and deploy a pull request to remove the role.

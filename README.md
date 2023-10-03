# k8s-role-change-guidance

![Latest Release](https://img.shields.io/github/v/release/zendesk/k8s-role-change-guidance?label=Latest%20Release)
![Tests](https://github.com/zendesk/k8s-role-change-guidance/workflows/Test/badge.svg?branch=main)

A custom Github Action for use on pull requests. The action:

 * looks for added / removed Kubernetes roles (under `./kubernetes`)
 * if there are any such roles, then adds a comment (unless already there)
   to the pull request explaining [how to merge and deploy safely](./guidance.md)
 * if there no such roles, then deletes any such comment

## Inputs

See `inputs` in [action.yml](https://github.com/zendesk/k8s-role-change-guidance/blob/main/action.yml).

## Output

This action has no outputs.

## Usage of the Github action

```yaml
---
name: Link changed markdown
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  k8s-role-change-guidance:
    runs-on: [ubuntu-latest]
    name: Kubernetes role change guidance
    steps:
      - uses: zendesk/checkout
      - uses: zendesk/k8s-role-change-guidance@VERSION
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

where VERSION is the version you wish you use, e.g. `v1.1.0` (or a branch, or a commit hash).
Check the top of this readme to find the latest release.

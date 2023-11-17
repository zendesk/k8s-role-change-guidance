# k8s-role-change-guidance

![Latest tag](https://img.shields.io/github/v/tag/zendesk/k8s-role-change-guidance?label=Latest%20tag)
![Tests](https://github.com/zendesk/k8s-role-change-guidance/actions/workflows/test.yml/badge.svg?branch=main)

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
name: Kubernetes Role Change Guidance
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  k8s-role-change-guidance:
    runs-on: [ubuntu-latest]
    name: Kubernetes role change guidance
    steps:
      - uses: zendesk/k8s-role-change-guidance@VERSION
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

where VERSION is the tag you wish you use, e.g. `v0.1` (or a branch, or a commit hash).
Check the top of this README for the latest tag, or consult
[the tags page](https://github.com/zendesk/k8s-role-change-guidance/tags) for more.

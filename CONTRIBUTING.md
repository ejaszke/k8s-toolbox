# Contributing Guide

## Scope

This repository contains Kubernetes tooling container configuration and usage documentation.

## Workflow

1. Create or switch to a feature branch.
2. Make focused changes.
3. Validate the changes locally.
4. Commit using Conventional Commits.
5. Open a pull request with a clear summary.

## Conventional Commits

Use commit messages in this format:

`<type>(<scope>): <short description>`

Scope is optional:

`<type>: <short description>`

Common types:

- `feat`: new functionality.
- `fix`: bug fix.
- `docs`: documentation-only changes.
- `refactor`: code change without behavior change.
- `chore`: maintenance tasks.
- `test`: test changes.
- `build`: build/dependency/image changes.

Breaking changes:

- Add `!` after type or scope, for example: `feat!: drop legacy kubeconfig format`.
- Include a `BREAKING CHANGE:` footer in the commit body when needed.

Examples:

- `docs(readme): add cluster access and csr steps`
- `build(dockerfile): pin kubectl and helm versions`
- `fix(kubeconfig): correct certificate-authority path`

## Pull request expectations

- Keep changes small and reviewable.
- Update `README.md` when behavior or usage changes.
- Do not include secrets, kubeconfig files, private keys, or certificates.

## Security notes

- Never commit files from `.kube` or `.ssh`.
- Redact hostnames, tokens, and internal endpoints from examples when needed.

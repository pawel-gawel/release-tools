# Release tools 

Implements my (at some point) preferred approach to version and release code.

This is pretty good scaffolding for future projects.

## Install

When installed (globally or as a dev dependency), you have access to `release` command.

To release new version of the repo you're currently working on, go with 

```
release [patch|minor|major]
```

## Releasing

Run with

```
./release.sh [patch|minor|major]
```

It will `npm version` codebase, push new commit and new tag to origin and open Github new release dialog with prepopulated tag. 

## Legacy

Legacy mechanism is based on git tags, as it was used in combination with CircleCI.

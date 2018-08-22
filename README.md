# Release tools 

Implements my (at some point) preferred approach to version and release code.

This is pretty good scaffolding for future projects.

## Releasing

Run with

```
./release.sh [patch|minor|major]
```

It will `npm version` codebase, push new commit and new tag to origin and open Github new release dialog with prepopulated tag. 

## Legacy

Legacy mechanism is based on git tags, as it was used in combination with CircleCI.

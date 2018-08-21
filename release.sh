#!/bin/bash 

set -e

owner=$(git config remote.origin.url | sed -n 's/.*:\(.*\)\/.*/\1/p')
repo=$(git config remote.origin.url | sed -n 's/.*\/\(.*\)\.git/\1/p')
version=$1

run() {
  if [[ ! $version =~ ^(patch|minor|major)$ ]]; then
    printf "\nInvalid version passed as a positional param, possible values are: patch, minor, major\n\n"
    exit 1
  fi

  printf "\n"
  read -p "This will npm version the repo, push the new commit and tag to Github and then go to new release page.

Are you sure you want to continue [y/n]? " agreed
  if [ "$agreed" != "y" ]; then
    printf "\n\tbye!\n\n"; exit
  fi

  tag=$(npm version $1 | tr -d v)
  
  git push
  git push origin $tag

  new_repo=https://github.com/${owner}/${repo}/releases/new?tag=$tag
  
  printf "\nNow publish new release on Github! $new_repo\n\n"

  open $new_repo
}

run $version


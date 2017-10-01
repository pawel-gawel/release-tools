#!/usr/bin/env bash

root_dir="$(dirname "$0")/"
. "${root_dir}colors.sh"

release_target="$1"
args="$*"

function release {
    git checkout master
    git pull
    git merge $2
    git tag $1
    if [[ " $args " =~ ' -n ' ]]; then
      printf "\n\nwould: \ngit push origin\ngit push --tags\n\n"
    else
      git push origin
      git push --tags
    fi
}

if [ "$release_target" != "qa" ] && [ "$release_target" != "prod" ] || [ -z "$1" ]; then
    printf "\n${RED}You have to provide proper target (qa, prod)! Like:${NC}\n
    .tools/elease.sh qa\n\n"
    exit 1
fi

# omitting safe locks
if [[ ! " $* " =~ ' -F ' ]]; then 
    if [[ $(git ls-files -m) ]]; then 
        printf "\n${RED}You have to have clean working directory to do that!\n\n"
        exit 1
    fi
fi

VERSION=$(git tag --points-at HEAD | grep '^v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}$')

if [ -z "$VERSION" ]; then
    printf "\n${RED}There is no proper version tag pointing at HEAD!${NC} \n
    ${GRAY}Try bump version with ${LIGHT_GRAY}.tools/bump-version.sh [major|minor|patch]${NC} \n\n"
    exit 1
fi

printf "\n=> Will release ${CYAN}$VERSION${NC}\n\n"

release_tag="$release_target-release/$VERSION"

printf "Checking if we have ${CYAN}$release_tag${NC} tag on remote ... \n"

if [[ $(git ls-remote origin refs/tags/$release_tag) ]]; then 
    printf "\n${RED}Version ${CYAN}$VERSION${NC} (with tag ${CYAN}$release_tag${NC}) already on remote! Aborting ...\n"
    exit 1
fi

if [[ "$* " =~ ' -f ' ]]; then 
    printf "\n=> Forcing release ... \n\n"
    release $release_tag $VERSION
else
    printf "\nSeems like everything is ready for ${CYAN}$VERSION${NC} release!\n\n"

    printf "App ${RED}$release_target$NC release of $CYAN$release_tag$NC is about to proceed.\n"
    read -p "Do you approve release process? If so, type 'yes': " approval

    if [[ $approval == "yes" ]]; then
        release $release_tag $VERSION
    else
        printf "\n${RED}Release aborted!${NC}"
    fi
fi

printf "\n\n"

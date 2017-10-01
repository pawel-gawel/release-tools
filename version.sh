#!/bin/bash

root_dir="$(dirname "$0")/"
. "${root_dir}colors.sh"

if [ -z "$1" ]; then
    local_version=$(git tag | grep v[0-9] | grep -v release | tail -1 | perl -pe 's/.*(v[\d+]\.[\d+].[\d+]).*/$1/g')
    remote_version=$(git ls-remote --tags | grep v[0-9] | grep -v release | tail -1 | perl -pe 's/.*(v[\d+]\.[\d+].[\d+]).*/$1/g')
    printf "\n\n${GRAY}Your local codebase version is ${LIGHT_GRAY}$local_version"
    printf "\n\n${GRAY}Latest remote repository codebase version is ${LIGHT_GRAY}$remote_version"
else 
    source .tools/bump-version.sh $@
fi

printf "\n\n"
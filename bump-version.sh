#!/usr/bin/env bash

root_dir="$(dirname "$0")/"
platform_specific_code_path="${root_dir}_platform-specific.sh"
bump_platform_version_function_name="bumpPlatformVersion"
. "${root_dir}colors.sh"
. $platform_specific_code_path 2> /dev/null

args="$*"

function setVersion {
    vtag="v$1"
    git pull 

    printf "\n=> Bumping application version to ${CYAN}$1${NC} ... \n\n"

    $bump_platform_version_function_name $1

    printf "\n=> Commiting and tagging ... \n\n"

    git add --all
    git cm "bump to version $1"
    git tag $vtag

    if [[ " $args " =~ ' -n ' ]]; then
      printf "\n\nwould:\ngit push origin\ngit push --tags\n\n"
    else
      git push origin
      git push --tags
    fi
}

if [ ! -f "$platform_specific_code_path" ]; then
    printf "\n${RED}Platform specific file missing!${NC}\n
    ${GRAY}There should be ${LIGHT_GRAY}$platform_specific_code_path${NC} ${GRAY}file \
with ${LIGHT_GRAY}$bump_platform_version_function_name${NC} ${GRAY}function defined\n\n"
    exit 1
fi

if [ -z "`declare -f -F $bump_platform_version_function_name`" ]; then
    printf "\n${RED}Bump version platform-specific function definition missing!${NC}\n
    ${GRAY}There should be ${LIGHT_GRAY}$bump_platform_version_function_name${NC} ${GRAY}defined, \
preferably inside ${LIGHT_GRAY}$platform_specific_code_path${NC} ${GRAY}file\n\n"
    exit 1
fi

# omitting safe locks
if [[ ! " $* " =~ ' -F ' ]]; then 
    if [[ ! $(git rev-parse --abbrev-ref HEAD) == "develop" ]]; then 
        printf "\n${RED}You have to be on develop branch to do that!${NC}\n\n"
        exit 1
    fi

    if [[ $(git ls-files -m) ]]; then 
        printf "\n${RED}You have to have clean working directory to do that!${NC}\n\n"
        exit 1
    fi
fi

BASE_STRING=$(git tag | grep v[0-9] | grep -v release | sort | tail -1 | perl -pe 's/v([\d+]\.[\d+].[\d+]).*/$1/g')
BASE_LIST=(`echo $BASE_STRING | tr '.' ' '`)

MAJOR=${BASE_LIST[0]} 
MINOR=${BASE_LIST[1]}
PATCH=${BASE_LIST[2]}

if [[ "$*" =~ "major" ]]; then 
    MAJOR=$((MAJOR+1))
    MINOR=0
    PATCH=0
elif [[ "$*" =~ "minor" ]]; then
    MINOR=$((MINOR+1))
    PATCH=0
elif [[ "$*" =~ "patch" ]]; then 
    PATCH=$((PATCH+1))
else
    printf "\n${RED}You have to provide version part as an argument (major, minor, patch)${NC}\n\n"
    exit 1
fi
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

if [[ ! $(echo $NEW_VERSION | grep '^[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}$') ]]; then 
    printf "\n${RED}Recognized new version ${CYAN}$NEW_VERSION${NC} is invalid!${NC}\n\n"
    exit 1
fi

if [[ $(git tag | grep "^v$NEW_VERSION$") ]]; then 
    printf "\n${RED}$NEW_VERSION is already defined in repo! Aborting ... ${NC}\n\n"
    exit 1
fi


if [[ " $* " =~ ' -f ' ]]; then 
    printf "\n=> Forcing version bump ... \n\n"
    setVersion $NEW_VERSION
else
    printf "\nSeems like everything is ready to bump app version to ${CYAN}$NEW_VERSION${NC}!\n\n"

    printf "Bumping app version is about to proceed, this will update codebase with new version, commit it an tag it with ${CYAN}$NEW_VERSION${NC}.\n"
    read -p "Do you approve this process? If so, type 'yes': " approval

    if [[ $approval == "yes" ]]; then
        setVersion $NEW_VERSION
    else
        printf "\n${RED}Bumping app version aborted!${NC}"
    fi
fi

printf "\n\n"
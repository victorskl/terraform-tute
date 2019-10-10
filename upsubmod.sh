#!/usr/bin/env bash

git submodule
printf "\n\n"

# https://stackoverflow.com/questions/5828324/update-git-submodule-to-latest-commit-on-origin
# shellcheck disable=SC2046
git submodule foreach git pull origin $(git rev-parse --abbrev-ref HEAD)

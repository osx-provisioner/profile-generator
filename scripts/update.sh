#!/bin/bash

# This script helps automate the process of updating a profile that has already been created.
# A branch "update-template" is created, with the changes required to update the profile.
# Use git cherry-pick (or create a patch from this change set) to update your Mac Maker profile.

# Before getting started carefully look at your profile's .cookiecutter/cookiecutter.json file.
# Compare it to the newest version of the template, and update any GitHub workflow action versions and add any
# new values that have since been included.

# Requires: https://pypi.org/project/cookiecutter-project-upgrader/

# 1:                                  The local filepath to the profile you'll be upgrading.
# 2:                                  The tag or branch of this repository you'll be using to perform the upgrade.
# PROFILE_GENERATOR_TEMPLATE_SOURCE:  Optionally repoint to forked remote repository, or a local zip bundle for the template.
# PROFILE_GENERATOR_UPDATE_BRANCH:    Optionally set a a branch name that will be created to house the proposed changes.

# Experimental end-user script.

set -eo pipefail

PROFILE_GENERATOR_TEMPLATE_SOURCE="${PROFILE_GENERATOR_TEMPLATE_SOURCE-"https://github.com/osx-provisioner/profile-generator.git"}"
PROFILE_GENERATOR_UPDATE_BRANCH="${PROFILE_GENERATOR_UPDATE_BRANCH-"update-template"}"

error() {
  echo "USAGE: ./update.sh [ROLE FOLDER] [TEMPLATE TAG or BRANCH] [--force]"
  exit 127
}

[[ -z $2 ]] && error
[[ -z $1 ]] && error

main() {

  pushd "$1" || error
  if [[ "$3" == "--force" ]]; then
    if git branch | grep "${PROFILE_GENERATOR_UPDATE_BRANCH}"; then
      set +eo pipefail
      git checkout main
      git reset origin/main
      git clean -fd .
      git branch -D "${PROFILE_GENERATOR_UPDATE_BRANCH}"
      rm -rf .git/cookiecutter
      set -eo pipefail
    fi
  fi

  TEMPLATE_SKIP_GIT_INIT=1 \
    TEMPLATE_SKIP_POETRY=1 \
    TEMPLATE_SKIP_PRECOMMIT=1 \
    cookiecutter_project_upgrader \
    -c .cookiecutter/cookiecutter.json \
    -b "${PROFILE_GENERATOR_UPDATE_BRANCH}" \
    -u "$2" \
    -f "${PROFILE_GENERATOR_TEMPLATE_SOURCE}" \
    -e "profile" \
    -e ".gitignore" \
    -e "LICENSE" \
    -e "README.md"

  git checkout update-template

  echo -e "\n==========="
  echo -e "\nThe following files differ from the template's newest version:"
  git diff HEAD~1 --summary
  echo -e "\nPlease review these changes carefully, and exit from this shell when finished.  Nothing has been pushed or merged yet."

  bash
  popd || true

}

main "$@"

#!/bin/bash

# scripts/test.sh
# Templates and builds a profile example with default values for testing.

# Development only script.

set -eo pipefail

OPTIONAL_TOML_LINTING=1

main() {

  rm -rf ../profile-example

  pushd .. || exit 127

    set -eo pipefail
      echo -e "\n\n${OPTIONAL_TOML_LINTING}\n\n\n\n\n" | cookiecutter profile-generator
      cd profile-example || exit 127
    set +eo pipefail
    echo -e "\nExit from this shell when finished testing ..."
    bash
  popd || exit 127

}

main "$@"
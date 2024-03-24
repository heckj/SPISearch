#!/usr/bin/env bash

# bash "strict" mode
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euxo pipefail

THIS_SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_DIR={$THIS_SCRIPT_DIR/..}

echo "PUSHING RELEASE BRANCH TO TRIGGER Xcode Cloud Build for TestFlight"

git checkout release
git rebase main release
git push origin release
git checkout main
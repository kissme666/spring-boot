#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="https://github.com/spring-projects/spring-boot.git"

if ! git remote get-url upstream &>/dev/null; then
  echo "Adding upstream remote: $UPSTREAM_URL"
  git remote add upstream "$UPSTREAM_URL"
else
  echo "upstream already exists: $(git remote get-url upstream)"
fi

echo "Fetching all branches and tags from upstream..."
git fetch upstream --tags

echo "Done. Upstream branches:"
git branch -r | grep upstream
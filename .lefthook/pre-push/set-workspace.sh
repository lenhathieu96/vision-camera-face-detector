#!/bin/bash

PACKAGE_JSON_PATH="path/to/package.json"

# Read the package.json file
packageJSON=$(cat "$PACKAGE_JSON_PATH")

# Check if workspaces key is not present
if [[ ! "$packageJSON" =~ "\"workspaces\":" ]]; then
  # Define workspaces array
  workspaces='["example"]'

  # Update the package.json file
  updatedPackageJSON=$(echo "$packageJSON" | jq --arg workspaces "$workspaces" '.workspaces = $workspaces')

  # Write the updated package.json file
  echo "$updatedPackageJSON" | jq . > "$PACKAGE_JSON_PATH"

  echo '✅ Workspaces set successfully.'
fi

#!/bin/bash

PACKAGE_JSON_PATH="package.json"

# Read the package.json file
packageJSON=$(cat $PACKAGE_JSON_PATH)

newPackageJSON=$(echo "$packageJSON" | jq 'del(.workspaces)')
# Update the package.json file
echo "$newPackageJSON" > $PACKAGE_JSON_PATH
echo "Workspaces removed successfully."
# Add the modified file to the Git commit
git add $PACKAGE_JSON_PATH

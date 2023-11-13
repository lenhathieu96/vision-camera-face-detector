#!/bin/bash

PACKAGE_JSON_PATH="package.json"

# Define workspaces
workspaces=("example")

# Read the package.json file
packageJSON=$(cat $PACKAGE_JSON_PATH)
newPackageJSON=$(echo "$packageJSON" | jq '. + { "workspaces": ['\"${workspaces[@]// /\",\"}\"'] }')
# Update the package.json file
echo "$newPackageJSON" > $PACKAGE_JSON_PATH
echo "Workspaces set successfully."

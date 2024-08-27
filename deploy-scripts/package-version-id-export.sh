#!/bin/bash

# Exit on error
set -euo pipefail

check_changed_submodule() {
   git diff-tree --no-commit-id --name-only -r HEAD | grep '^packages/' | cut -d'/' -f1-2 || echo ""
}

verify_submodule_change() {
   if [ -z "$1" ] || [ "$1" == "null" ]; then
      echo "No submodule commited. Exiting with 0."
      exit 0
   fi
   git submodule init
   git submodule update "$1"
   echo "Changed submodule detected: $1"
   if [ ! -f "$1/sfdx-project.json" ]; then
      echo "The submodule $1 is not a valid sfdx project. Missing sfdx-project.json."
      exit 0
   fi
   echo "$1 is a valid sfdx project. Proceeding."
}

get_package_id_from_changed_submodule() {
   packageName=$(jq -r '.packageDirectories[] | select(.path == "src/packaged") | .package' "$1/sfdx-project.json")
   jq -r --arg package "$packageName" '.packageAliases[$package]' "$1/sfdx-project.json"
}

verify_package_id_extract() {
   if [ -z "$1" ] || [ "$1" == "null" ]; then
      echo "Failed to extract valid package id from commited package."
      exit 101
   fi
   if [[ "$1" != 0Ho* ]]; then
      echo "Unexpected format for extracted package id: $1. Something wrong with sfdx-project.json?"
      exit 102
   fi
   echo "Package Id: $1"
}

extract_package_version_literal() {
   rawVersionNumberLiteral=$(jq -r '.packageDirectories[] | select(.path == "src/packaged") | .versionNumber' "$1/sfdx-project.json")
   echo "${rawVersionNumberLiteral%.NEXT}"
}

verify_package_version_literal() {
   echo "Identified package version: $1"
   if [ -z "$1" ] || [ "$1" == "null" ]; then
      echo "Failed to read package version number from sfdx-project.json."
      exit 104
   fi
}

query_package_subscriber_id() {
   echo "sf data query --use-tooling-api --json --query $1 --target-org $2"
   mkdir -p tmp
   sf data query --use-tooling-api --json --query "$1" --target-org "$2" > tmp/sf-data-query-result.json
   jq '.' tmp/sf-data-query-result.json
   jq -r '.result.records[0].SubscriberPackageVersionId' tmp/sf-data-query-result.json > tmp/subscriber-version-id.txt
}

build_subscriber_version_query() {
   IFS='.' read -ra versionArray <<< "$2"
   echo "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '$1' AND MajorVersion = ${versionArray[0]} AND MinorVersion = ${versionArray[1]} AND PatchVersion = ${versionArray[2]} AND IsReleased = true"
}

verify_subscriber_package_id() {
   if [ -z "$1" ] || [ "$1" == "null" ]; then
      echo "Failed to get subscriberVersionId. Is there already a released package version?"
      exit 102
   fi
   if [[ "$1" != 04t* ]]; then
      echo "Unexpected format for subscriberVersionId $1"
      exit 103
   fi
   echo "Subscriber Package Id: $subscriberVersionId"
}

parameter_verification() {
   # Check if PARAM_DEVHUB_USERNAME is set correctly
   if [ -z "$PARAM_DEVHUB_USERNAME" ] || [ "$PARAM_DEVHUB_USERNAME" == "null" ]; then
      echo "DevHub org name is not set or empty"
      exit 201
   fi
   # Check if PARAM_SUBSCRIBER_VERSION_EXPORT is set correctly
   if [ -z "$PARAM_SUBSCRIBER_VERSION_EXPORT" ] || [ "$PARAM_SUBSCRIBER_VERSION_EXPORT" == "null" ]; then
      echo "Subscriber version export is not set or empty"
      exit 202
   fi
}

export_subscriber_id_to_env_var() {
   echo "Exporting release version $1 to $2"
   echo "export $2=$1" >> "$BASH_ENV"
}

export_package_id_to_env_var() {
   echo "Exporting package id $1 to $2"
   echo "export $2=$1" >> "$BASH_ENV"
}

main() {
   parameter_verification
   changedSubmodule=$(check_changed_submodule)
   verify_submodule_change "$changedSubmodule"
   packageId=$(get_package_id_from_changed_submodule "$changedSubmodule")
   verify_package_id_extract "$packageId"
   export_package_id_to_env_var "$packageId" "PACKAGE_ID"
   versionLiteral=$(extract_package_version_literal "$changedSubmodule")
   verify_package_version_literal "$versionLiteral"
   toolingApiQuery=$(build_subscriber_version_query "$packageId" "$versionLiteral")
   query_package_subscriber_id "$toolingApiQuery" "$PARAM_DEVHUB_USERNAME"
   subscriberVersionId=$(cat tmp/subscriber-version-id.txt)
   verify_subscriber_package_id "$subscriberVersionId"
   export_subscriber_id_to_env_var "$subscriberVersionId" "$PARAM_SUBSCRIBER_VERSION_EXPORT"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
   main
fi
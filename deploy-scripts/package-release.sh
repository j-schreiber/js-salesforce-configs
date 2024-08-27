#! /bin/bash
set -e

repoName=
packageVersion=
while getopts r:v: option; do
    case "${option}" in
    r) repoName=${OPTARG} ;;
    v) packageVersion=${OPTARG} ;;
    *) ;;
    esac
done

if [ -z "$repoName" ]; then
    echo "Must enter a repository name!"
    exit 1
fi

# updating repos
git pull
cd "packages/$repoName" || exit

if [ -z "$packageVersion" ]; then
    git checkout master
    git pull
else
    git checkout "v$packageVersion" || exit
fi

cd ../..

packageName=$(jq -r '.packageDirectories.[] | select(.path == "src/packaged") | .package' packages/$repoName/sfdx-project.json)
rawVersionName=$(jq -r '.packageDirectories.[] | select(.path == "src/packaged") | .versionNumber' packages/$repoName/sfdx-project.json)
versionName=${rawVersionName%.NEXT}

# sanitiy checking data
echo "Updating packages/$repoName"
echo "Extracting package name: $packageName"
echo "Extracting package version: $versionName"

# preparing commit
git add "packages/$repoName"
git commit -m "$packageName @ $versionName"

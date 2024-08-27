#! /bin/bash
set -e

scriptPath=
while getopts f: option; do
    case "${option}" in
    f) scriptPath=${OPTARG} ;;
    *) ;;
    esac
done

scriptName="${scriptPath##*/}"
wget "https://raw.githubusercontent.com/j-schreiber/js-salesforce-configs/main/deploy-scripts/$scriptName"
mv "$scriptName" "$scriptPath"
git add "$scriptPath"
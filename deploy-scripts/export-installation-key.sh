#! /bin/bash
# shellcheck disable=SC1091

get_changed_submodule() {
   git diff-tree --no-commit-id --name-only -r HEAD | grep '^packages/' | cut -d'/' -f1-2 || echo ""
}

read_installation_key_name() {
    submoduleName=${1#packages/}
    keyName=$(grep "$submoduleName" scripts/.config/keys.conf)
    if [ -z "$keyName" ]; then
        echo "No installation key mapping found for $submoduleName in keys.conf."
        echo "Will try to install package without key."
        exit 0
    fi
    keyValue=${keyName#"$submoduleName"=}
    if [ -z "${!keyValue}" ]; then
        echo "No installation key exported for $keyValue."
        echo "Will try to install package without key."
    else
        echo "Installation key ${!keyValue} found for $keyValue. Exporting to $2 for package install."
        echo "export $2=${!keyValue}" >> "$BASH_ENV"
    fi
}

changedSubmodule=$(get_changed_submodule)
read_installation_key_name "$changedSubmodule" "$PARAM_EXPORT_VARIABLE_NAME"
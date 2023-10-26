Maintains and provisions scratch org definition files for all Salesforce packages. Packages manually check out the most recent scratch def during package version setup.

Similar to `npm ci`, the scratch def is committed and does not dynamically change during build time. A developer has to manually upgrade it from this repository.

## Getting Started

It is recommended to have the following tools installed on your machine

    - **wget**: Retrieve file from scratch def
    - **jq**: Modify the scratch def file after retrieval
    - **prettier**: Format file after retrieval

## How To Integrate in Setup

Copy this snippet in a local script that is executed manually. Do not integrate this into your CI.

```bash
scratchOrgName="YOUR_SCRATCH_ORG_NAME"
wget https://raw.githubusercontent.com/j-schreiber/js-salesforce-configs/main/scratch-org-defs/default-scratch-def.json
jq --arg a "${scratchOrgName}" '.orgName = $a' default-scratch-def.json > config/default-scratch-def.json
rm -f default-scratch-def.json
./node_modules/.bin/prettier --write 'config/default-scratch-def.json'
```
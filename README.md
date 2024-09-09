Maintains and provisions scratch org definition files for all Salesforce packages. Packages manually check out the most recent scratch def during package version setup.

Similar to `npm ci`, the scratch def is committed and does not dynamically change during build time. A developer has to manually upgrade it from this repository.

## Getting Started

It is recommended to have the following tools installed on your machine

- **wget**: Retrieve file from scratch def
- **jq**: Modify the scratch def file after retrieval
- **prettier**: Format file after retrieval
- **bats**: Testing utility for [shell scripts](deploy-scripts)

### Shell Dev Environment

For developing bash scripts, use Docker. Strongly discouraged to develop shell scripts on your local machine, because it may use a different bash version (or entirely different shell) that the one that is being used in our CI.

```bash
# Open the "docker hub", this will automatically start the background daemon
open -a Docker

# check if deamon is running
docker info

# launch the local dev environment
docker compose up -d && docker compose exec shelldeveloper bash
```

## How To Integrate in Setup

Copy this snippet in a local script that is executed manually. Do not integrate this into your CI.

```bash
scratchOrgName="YOUR_SCRATCH_ORG_NAME"
wget https://raw.githubusercontent.com/j-schreiber/js-salesforce-configs/main/scratch-org-defs/default-scratch-def.json
jq --arg a "${scratchOrgName}" '.orgName = $a' default-scratch-def.json > config/default-scratch-def.json
rm -f default-scratch-def.json
./node_modules/.bin/prettier --write 'config/default-scratch-def.json'
git add config/default-scratch-def.json
git commit -m 'ops: update to latest scratch org def'
```

## Notes

`AdditionalFieldHistory` is used to set a fix limit for field history tracking. As a workaround it is increased (default limit is 20), because Salesforce sometimes enables field tracking for standard fields, which are not enabled on our sandboxes. In our case of having 20 fields tracked on a sandbox, the scratch org exceeded the limit, because of the default tracked standard fields and broke the pipeline. For reference see: [Salesforce Case #467469092](https://help.salesforce.com/s/case-view?caseId=500Hx00000UskEJIAZ)
Scripts in this folder are not (yet) packaged in the jsc/salesforce orb. For now, these scripts are maintained 
and duplicated in the individual repositories, until we found a better way.

To update them, run this snippet from the target repository. This repository should be used as template
and source of truth. Copy the `update-deploy-script.sh` to your target repository.

```bash
bash update-deploy-script.sh -f scripts/check-subscriber-id-export.sh
bash update-deploy-script.sh -f scripts/export-installation-key.sh
bash update-deploy-script.sh -f scripts/package-release.sh
bash update-deploy-script.sh -f scripts/package-version-id-export.sh
git commit -m 'ops: update deploy scripts to latest'
```
Maintains and provisions scratch org definition files for all Salesforce packages. Packages manually check out the most recent scratch def during package version setup.

Similar to `npm ci`, the scratch def is committed and does not dynamically change during build time. A developer has to manually upgrade it from this repository.

## Getting Started

It is recommended to have the following tools installed on your machine

- **wget**: Retrieve file from scratch def
- **jq**: Modify the scratch def file after retrieval
- **prettier**: Format file after retrieval

## How To Integrate in Setup

Use the provided template [update-scratch-def.sh](scripts/update-scratch-def.sh) and copy it's contents to your local package directory. It is not recommended to integrate this in CI.

## Notes

`AdditionalFieldHistory` is used to set a fix limit for field history tracking. As a workaround it is increased (default limit is 20), because Salesforce sometimes enables field tracking for standard fields, which are not enabled on our sandboxes. In our case of having 20 fields tracked on a sandbox, the scratch org exceeded the limit, because of the default tracked standard fields and broke the pipeline. For reference see: [Salesforce Case #467469092](https://help.salesforce.com/s/case-view?caseId=500Hx00000UskEJIAZ)
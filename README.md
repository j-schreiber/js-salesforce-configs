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

```
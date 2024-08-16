---
name: Clear CI artifacts
about: Request clearing of corrupt CI artifacts
title: Clear corrupt CI artifacts for server-edition/<CI RUN NUMBER>
labels: ""
assignees: ""
---

Please clear the CI artifacts for the following CI run:

- Project: server-edition
- CI run number: (please fill in; don't forget to update the title too)

<!--
You can find out the CI run number as follows:

 1. In the affected CI run, go to the "Determine necessary jobs" job.
 2. View the logs for any "Determine whether XXX needs to be built" step.
 3. You should see a message like this:

        Checking gs://fullstaq-ruby-server-edition-ci-artifacts/<CI RUN NUMBER>/XXXX

    That's the CI run number.
-->

## Instructions for infra team members

See [this guide](https://github.com/fullstaq-ruby/infra/blob/main/docs/clearing-ci-artifacts.md).

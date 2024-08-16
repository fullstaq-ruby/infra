# Clearing CI artifacts

Once in a while, developers may request that we clear CI artifacts. This is because CI artifacts — which are stored in a Google Cloud Storage bucket — could become corrupted (e.g. due to network issues). When this happens, developers are blocked until we resolve this issue. This, speedy handling of such issues is important.

Developers request the clearing of CI artifacts via the issue tracker, using [this template](../.github/ISSUE_TEMPLATE/clear_ci_artifacts.md).

## How to process the support request

Here's how you should process such a support request:

1.  Go to the Google Cloud Storage bucket named [fullstaq-ruby-server-edition-ci-artifacts](https://console.cloud.google.com/storage/browser/fullstaq-ruby-server-edition-ci-artifacts?project=fullstaq-ruby) in the `fullstaq-ruby` project.
2.  Delete the folder whose name equals the reported CI run number.
3.  Close the issue with the following canned response:

    > The artifacts have been cleared. Please re-run the CI job whenever convenient.

## See also

- [Troubleshooting corrupt CI/CD artifacts — Server Edition development handbook](https://github.com/fullstaq-ruby/server-edition/blob/main/dev-handbook/troubleshooting-corrupt-ci-cd-artifacts.md)

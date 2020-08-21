## Description

<!--
Please describe:

 - What this PR changes.
 - Why (rationale, what problem it solves).
 - Caveats to be aware of, e.g. potential downtime once this change gets deployed.
 - Whether any manual migration must be performed, and how.
-->

## Testing instructions

<!--
Please describe how to test this change, after it has been deployed to production.
-->

## Checklist for the submitter

<!--
Check a box by filling in 'x', like so...

 - [x] Checklist item

...or mark it as not applicable, like so:

 - [ ] ~~Checklist item~~
-->

 - [ ] Documentation updated
 - [ ] Infrastructure overview diagram updated
   <!-- see docs/editing-diagrams.md to learn how to edit the diagram -->
 - [ ] The following content/files are kept in sync with each other:
   + The Terraform version specified in `**/providers.tf`, `.github/workflows/code-reviews.yml` and `docs/required-devtools.md`

## Checklist for reviewers

- [ ] If `terraform-hisec/` was updated: someone with the "Infra Owner" role has checked the output of `terraform plan`

## Definition of done (for team members)

This checklist is for the person who merges this pull request. _Tick check boxes, or strike out irrelevant ones._

 - [ ] If `terraform-hisec/` was updated: someone with the "Infra Owner" role has run `terraform apply`
 - [ ] Tested in production

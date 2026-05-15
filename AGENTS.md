This is the infra-as-code repo for Fullstaq Ruby. Consult README.md and `docs/` to learn more about the codebase, especially [Infrastructure overview](docs/infrastructure-overview.md).

# Directory structure

- `terraform-hisec/`: tier-0 infrastructure that only a limited subteam (Infra Owners) can touch.
- `terraform/`: normal infrastructure that all team members can touch.
- `ansible/`: playbook for the server backend.fullstaqruby.org which hosts the domains {apt,yum}.fullstaqruby.org.
- `apiserver/`: a Ruby HTTP API app, deployed to backend.fullstaqruby.org, with and endpoint allowing the APT/YUM publishing jobs to notify the server that new packages have been uploaded.

# Github Workflows review instructions (ALWAYS FOLLOW)

Review not only for correctness, but also security (VERY IMPORTANT):

- Consult security checklists:
  https://aquilax.ai/blog/github-actions-security-hardening
  https://www.wiz.io/blog/github-actions-security-guide
- Learn insights from the Tanstack postmortem: https://snyk.io/blog/tanstack-npm-packages-compromised/
- Beware of cache poisoning opportunities.
- Review transitive Github Actions dependencies too.

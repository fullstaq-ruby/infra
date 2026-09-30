# API server

The API server is a small service that exposes a couple of privileged management
operations to the project's GitHub Actions workflows — primarily so that CI can
trigger restarts of Caddy and self-upgrades of the API server itself, without
needing SSH access to the backend host.

It runs as a systemd-managed Puma process (`apiserver.service`) on the Hetzner
backend host, listening on a Unix socket at `/run/apiserver/server.sock`. Caddy
reverse-proxies the `/admin/*` paths from `apt.fullstaqruby.org` and
`yum.fullstaqruby.org` to that socket — there is no dedicated `apiserver.*`
hostname.

## Endpoints

- `GET /` — health check, returns `ok`.
- `POST /admin/upgrade_apiserver` — kicks off `apiserver-deployer` (which fetches
  the latest API server release from GitHub and activates it), then restarts
  `apiserver` itself. Callable only from `fullstaq-ruby/infra`'s `deploy`
  GitHub Actions environment.
- `POST /admin/restart_web_server` — restarts Caddy. Callable only from
  `fullstaq-ruby/server-edition`'s `deploy` GitHub Actions environment.

## Authentication

The API server authenticates callers using **GitHub Actions OIDC**. Every
request must carry an `Authorization: Bearer <token>` header where the token
is an ID token minted by GitHub's OIDC provider with audience claim
`backend.fullstaqruby.org`. The server verifies the JWT signature against
GitHub's JWKS and rejects the request unless the token's `repository`, `sub`,
`runner_environment`, and `environment` claims match the calling repo's
expected `deploy` environment for that endpoint.

Because the audience and claim shape are tied to GitHub-hosted runners, the
endpoints are not callable directly by a human or from a local machine.

## Continuous deployment

API server builds and deployments are driven by two workflows in
`.github/workflows/`:

- **Test and build** (`test-and-build.yml`) runs on every push. When a push
  touches `apiserver/**`, its `apiserver-build` job packages the API server
  into a tarball and uploads it as a workflow artifact.
- **Deploy** (`deploy.yml`) runs after a successful Test and build run on
  `main`. It tags the commit, publishes a GitHub release with the tarball, and
  calls `POST https://apt.fullstaqruby.org/admin/upgrade_apiserver` with a
  freshly minted OIDC token.

On the host, `apiserver-deployer` (a oneshot systemd unit running
`/usr/local/bin/apiserver-deployer`) handles the actual install: it fetches
the latest release metadata from the GitHub API, downloads the asset matching
the host's distribution and architecture, extracts it into
`/opt/apiserver/versions/<tag>-<dist>-<version>-<arch>`, installs any runtime
dependencies declared in `dpkg-dependencies.txt`, prunes all but the last five
versions, and atomically swaps the `/opt/apiserver/versions/latest` symlink.
The API server's working directory points at that symlink, so the subsequent
`systemctl restart apiserver` brings the new version online.

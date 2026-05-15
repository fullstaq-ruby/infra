# `infra/ansible/` — Hetzner VM playbook

Configures `backend.fullstaqruby.org`. See `../docs/` for operational context.

## Local testing with Molecule + Lima

This playbook ships a Molecule scenario that converges the playbook against a
Lima VM, with all live external dependencies (Azure Key Vault, GCS, GitHub
releases) replaced by stubs so the scenario runs offline-friendly without
cloud credentials.

### One-time setup (macOS)

```
brew install lima uv
uv tool install --with ansible-core==2.20.5 --with molecule-plugins==25.8.12 --python 3.12 molecule==26.4.0
```

Versions match `requirements.txt`, which is the canonical pin source for this
scenario. Bump both together when upgrading.

`uv tool install` puts each tool in its own isolated venv. Molecule shells out
to `ansible`, `ansible-playbook`, `ansible-config`, etc., so the entire tool
venv's `bin/` directory must be on PATH — adding only the `molecule` symlink
isn't enough. Add this to your shell rc (or run per-session):

```
export PATH="$HOME/.local/share/uv/tools/molecule/bin:$PATH"
```

Install the Ansible collections the playbook depends on:

```
ansible-galaxy collection install community.general ansible.posix
```

### Daily loop

From this directory (`infra/ansible/`):

```
molecule converge        # iterative; keeps VM alive between runs
molecule verify          # run assertions against the converged VM
molecule idempotence     # second-run check (changed=0)
molecule destroy         # tear down the Lima VM
molecule test            # full lifecycle: destroy → create → prepare → converge → idempotence → verify → destroy
```

Approximate timings on Apple Silicon (arm64 native guest):

- VM boot: ~20s
- First converge: ~3–5 min (apt installs + bundle install of fixture)
- Subsequent converges: ~30–60s
- Verify: ~10s

### What the scenario does

- Boots a Debian 12 cloud-image VM via Lima (`molecule/default/lima.yaml`)
- Bootstraps packages the prod playbook assumes preinstalled (cron, ufw,
  acl, rsyslog, ruby-dev, build-essential — see
  `molecule/default/prepare.yml`)
- Runs `main.yml`'s task list with `molecule_test: true`, which causes four
  prod tasks to skip live external calls
- Stages a service-contract fixture (minimal Sinatra app on Puma) at
  `/opt/apiserver/versions/latest` so the apiserver systemd unit can start
  successfully
- Verifies that `caddy`, `prometheus`, `fail2ban`, `ssh`, and `apiserver`
  are all `systemctl is-active`, that the apiserver Unix socket exists, that
  `caddy validate` passes, and that SSH/UFW/unattended-upgrades configuration
  matches expectations

### Inspecting the VM

```
limactl shell ansible-molecule          # interactive shell on the VM
limactl shell ansible-molecule sudo systemctl status caddy
limactl shell ansible-molecule sudo journalctl -u apiserver
```

### Troubleshooting

- **`No version is set for command molecule`** — your shell is using asdf
  shims that shadow the uv-installed binaries. Make sure
  `~/.local/share/uv/tools/molecule/bin` is *before* asdf's shim dir on PATH.
- **`Could not find or access '<file>.j2'` or `<file>.sh`** — a `files/` or
  `templates/` symlink in `molecule/default/` may be missing or broken; both
  must point to `../../files` and `../../templates` respectively.
- **`limactl: command not found`** — `brew install lima`.
- **VM in a wedged state** — `molecule destroy` then re-run. As a last resort:
  `limactl delete --force ansible-molecule`.

### What is *not* tested by this scenario

- Real ACME/TLS issuance (test Caddyfile uses `auto_https off`)
- Real Azure Key Vault, GCS, or GitHub-release integration
- OIDC JWT verification (covered by `../apiserver/` Ruby tests)
- Live `fail2ban` banning behavior (only verifies the unit starts cleanly)
- AppArmor profile loading (the playbook only installs the package today)

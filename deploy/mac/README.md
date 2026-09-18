# Mac service

The maintained source runs as user LaunchAgent `com.martin.cyrus`. It starts at
login and restarts after worker or tunnel exit. The worker binds to localhost;
the existing tunnel exposes `https://cyrus.martinm.co`.

## Runtime

- Node: `/opt/homebrew/Cellar/node/26.8.2/bin/node`.
- Cyrus: this checkout's `apps/cli/dist/src/app.js`, version 0.2.72.
- Codex: `/Users/martin/.local/bin/codex`, currently 0.154.0. This existing
  managed executable may update independently; Cyrus source updates are manual.
- Cloudflared: `.runtime/bin/cloudflared`, copied from the existing installation,
  version 2026.9.1. SHA-256:
  `9a0b19f67dc7a3011bc6b972c7ce06a5fcea8784ac6bd599ffa382ea4aeb5a6e`.
  Tunnel auto-update is disabled. This ignored binary must be provisioned when
  recreating this checkout; the tracked source alone is not a complete runtime.
- State and OAuth: `~/.cyrus`; no `.env` file is needed.
- Issue runner: `defaultRunner=codex`, `codexDefaultModel=gpt-5.6-sol`, and
  `codexDefaultReasoningEffort=low` in `~/.cyrus/config.json`. The maintained
  fork recognizes existing Linear `GPT-5.6 Sol` and effort labels. Change the
  config through an atomic, backed-up writer, then restore mode 600 (the
  project-bootstrap writer currently creates a mode-644 replacement); reload
  it before delegation.
- Secrets: existing Bitwarden items, cached by `./loadSecrets.sh` in Keychain.
  `runCyrus.sh` reads the four caches and exports the GitHub token to children.
- Log: `~/Library/Logs/cyrus.log`, mode 600. No log rotation is installed yet.

The service owns both worker and tunnel. Either exiting stops its sibling, then
launchd restarts the launcher with a 30-second throttle. A duplicate foreground
worker is refused. `runCyrus.command` provides foreground ownership when the
LaunchAgent is unloaded; Ctrl-C stops both children. No browser is required.

## Commands

```bash
./runCyrus.sh check
CYRUS_CHECK_SANDBOX=1 ./runCyrus.sh check
launchctl print gui/$(id -u)/com.martin.cyrus
curl -fsS https://cyrus.martinm.co/status
```

The check authenticates existing Linear and GitHub credentials. Its optional
sandbox probe performs only a GitHub API read under Codex workspace-write with
network enabled; it calls no model and creates no issue, branch, or PR. A raw
Linear check can fail when an access token expires; the running upstream Linear
client automatically renews it with the existing refresh token on a 401.

Stop persistently for maintenance:

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.martin.cyrus.plist
```

Start again:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.martin.cyrus.plist
```

Check `/status` is `idle` before deliberately restarting. Killing the worker or
tunnel alone is not a stop command; supervision brings the service back.

## Updates and rollback

Fetch `upstream`, review changes, and merge into the maintained branch. Stop the
service before rebuilding its live checkout, run the locked install, build and
appropriate checks, then bootstrap and verify local/public version and status.
Do not automatically deploy upstream main or run global npm updates.

The previous package installation remains at
`/Users/martin/db/code2/productivity/cyrus-trial`. A post-renewal configuration
backup is `~/.cyrus/backups/config-before-launchd-20260918.json`. Earlier config
backups also exist. Stop this LaunchAgent before using the old foreground
launcher. Do not restore an old expired OAuth token merely to roll code back.

## Verification boundaries

Mac service startup, public status/version, launchd-context credentials,
sandbox-authenticated GitHub reads, separate worker/tunnel failure recovery,
and clean unload/reload passed during deployment. A sandboxed authenticated
`git push --dry-run` to the `mgenart` remote also passed after the Sol/low
configuration change; it created no branch and is not proof of a real PR.
Login/reboot and sleep/wake behaviour need natural lifecycle observations.
Offline delegation, full F1 session execution, and push/PR delivery remain in
the installation plan. No model-assisted task was dispatched in this deployment.

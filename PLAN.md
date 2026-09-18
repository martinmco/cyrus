# Cyrus

## Where we are

| Workstream | Current state | Immediate next outcome |
|---|---|---|
| ✅ Initiative | Cyrus Initiative created; existing project renamed Cyrus Installation and linked | Maintain one durable system home |
| ✅ Maintained fork | martinmco/cyrus fork; origin points to fork, upstream to cyrusagents/cyrus | Review upstream updates before deploying |
| ✅ Source installation | Lockfile dependencies installed; full source build passes; CLI reports 0.2.72 | Deploy the built fork |
| 🟡 Service lifecycle | Existing foreground 0.2.71 installation is stopped; host choice requested | Choose Mac launchd, mCloud, or foreground |
| ⬜ Connections and sandbox | Existing credentials and routes preserved; GitHub token accepted outside sandbox | Verify actual runner access and PR delivery |

## Current work

Martin approved adopting Cyrus as a maintained self-hosted system on 18 September 2026. The former evaluation does not gate installation. Active work uses installation and operational acceptance language; historical records remain evidence.

Canonical source: `/Users/martin/db/Projects/cyrus`. Fork: https://github.com/martinmco/cyrus. Upstream: https://github.com/cyrusagents/cyrus. Local installation changes start on `codex/maintained-install`. Keep main compatible with upstream and review, build, and validate updates before deployment; never update the running service blindly.

System home: https://linear.app/uptickstudio/initiative/cyrus-9e254f735757. The initiative route is `route/cy-4244`, currently not wired to a repository. Existing runtime state and OAuth credentials live outside this public fork under `~/.cyrus`; secrets remain Bitwarden-owned with the existing Keychain cache. No credentials belong in Git.

The built upstream baseline is `e9e1e53d629b023545ebfd821bcd16c67f44f217`. The old installation remains untouched at `/Users/martin/db/code2/productivity/cyrus-trial` until deployment and rollback are defined. Its name is historical, not the new operating model.

## Remaining work — single backlog

1. Resolve service host and lifecycle: Mac launchd, mCloud, or foreground. Do not deploy before this choice.
2. Prepare repo-local launchers, pinned executable paths, safe logging, backups, and rollback for the chosen host. Preserve valid OAuth rather than rotating it without cause.
3. Reconcile routing through the locked configuration writer: remove obsolete Arkanoid routing, register this fork, and use the initiative route. Check the five existing real routes.
4. Verify Linear credentials, tunnel delivery, sandbox file boundaries, environment token propagation, and GitHub operations in the actual execution context. No model call is needed for credential and command probes.
5. Complete operational acceptance: stop/restart, health visibility, offline delegation behaviour, and the upstream F1 protocol. Model-assisted validation requires an explicitly selected approved model; do not run the existing terra default incidentally.
6. Delegate one useful bounded change in an existing project and independently verify tests, commit, push, PR, and terminal Linear activity. This is installation acceptance, not a decision about whether to adopt Cyrus. Select the actual task before delegation.
7. Reconcile historical evaluation issues and milestones into the installation backlog without deleting evidence or marking unfinished work complete.

## Completed foundation

- GitHub fork created and cloned; upstream remote configured.
- Cyrus initiative created; Cyrus Installation project renamed, linked, and read back.
- `corepack pnpm install --frozen-lockfile` and `corepack pnpm build` pass; built CLI version check returns 0.2.72.
- No live service started, model turn spent, OAuth rotated, or old installation moved.

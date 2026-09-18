# Cyrus

## Where we are

| Workstream | Current state | Immediate next outcome |
|---|---|---|
| ✅ Initiative | Cyrus Initiative created; existing project renamed Cyrus Installation and linked | Maintain one durable system home |
| ✅ Maintained fork | martinmco/cyrus fork; origin points to fork, upstream to cyrusagents/cyrus | Review upstream updates before deploying |
| ✅ Source installation | Lockfile dependencies installed; full source build passes; CLI reports 0.2.72 | Review upstream updates before deployment |
| ✅ Mac service deployment | Launchd startup, public status/version, both failure-recovery checks and unload/reload pass | Observe natural login and sleep/wake behaviour |
| ✅ Routing cleanup | Obsolete Arkanoid removed; maintained fork wired; doctor reports no hazards | Verify real Linear delegation |
| 🟡 Connections and sandbox | Existing OAuth renewed; launchd credential check and sandbox GitHub read pass | Verify push/PR delivery with a useful task |
| ✅ Runner selection | Codex default is GPT-5.6 Sol, low reasoning; friendly Linear model/effort labels resolve and relaunched service is healthy | Confirm the actual model and effort in the first issue session |
| ✅ Ready-for-review guidance | Installed user-level `verify-and-ship` override documents ready-state handoff, `isDraft=false` read-back, reporting, and no merge | Apply it to completed GitHub work; Martin reviews and merges |

| ✅ Worktree setup hook | Removed obsolete `/Users/cyrusops` instructions copy; fresh and repeat setup checks pass | New worktrees use the maintained hook |

## Current work

The setup-hook repair removes the obsolete machine-specific instructions copy while retaining issue-port configuration. Fresh-worktree and repeat-run checks cover startup, port updates, and preservation of unrelated configuration.

Martin approved adopting Cyrus as a maintained self-hosted system on 18 September 2026. The former evaluation does not gate installation. Active work uses installation and operational acceptance language; historical records remain evidence.

Canonical source: `/Users/martin/db/Projects/cyrus`. Fork: https://github.com/martinmco/cyrus. Upstream: https://github.com/cyrusagents/cyrus. Local installation changes start on `codex/maintained-install`. Keep main compatible with upstream and review, build, and validate updates before deployment; never update the running service blindly.

System home: https://linear.app/uptickstudio/initiative/cyrus-9e254f735757. The initiative route `route/cy-4244` is wired to this fork, with `Cyrus Installation` as the project-name fallback and `codex/maintained-install` as the base branch. Existing runtime state and OAuth credentials live outside this public fork under `~/.cyrus`; secrets remain Bitwarden-owned with the existing Keychain cache. No credentials belong in Git.

The built upstream baseline is `e9e1e53d629b023545ebfd821bcd16c67f44f217`. Martin selected Mac launchd with existing connections. The maintained service is `com.martin.cyrus`; setup, commands and rollback are in [deploy/mac/README.md](deploy/mac/README.md). The previous package installation remains preserved at `/Users/martin/db/code2/productivity/cyrus-trial`. Its name is historical, not the new operating model. The current issue-session default is Codex `gpt-5.6-sol` at `low` effort; issue labels or description selectors may override it.

The maintained Mac installation also has a user-level `verify-and-ship` override
at `~/.cyrus/user-skills-plugin/skills/verify-and-ship/SKILL.md`. It is agent
guidance: it requires `gh pr ready` and a read-back confirming `isDraft=false`
unless explicit instructions require keeping the PR Draft, and requires clear
reporting of failed or unavailable checks. It does not enforce behavior in the
worker; agents must not merge or enable auto-merge, and Martin reviews and
merges from Linear. See [Mac operations](deploy/mac/README.md) for the full
handoff rule.

## Remaining work — single backlog

1. Complete sandbox boundary and GitHub write checks in the actual runner context. An authenticated sandboxed `git push --dry-run` to `mgenart` succeeds; an actual branch push and PR remain to be observed.
2. Complete operational acceptance: natural login/reboot and sleep/wake observations, actual Linear webhook delivery, offline delegation behaviour, and full upstream F1 session execution. Model-assisted validation requires an explicitly selected approved model; no turn is spent by a configuration check.
3. Delegate one useful bounded change in an existing project and independently verify tests, commit, push, PR, and terminal Linear activity. SYS-18 is Martin's proposed manual delegation: the Cyrus actor can read it, the real router selects mgenart by mg-b9bb, and the clone is clean. The historical Arkanoid failure was missing/invalid GitHub CLI authentication; the new token passes a sandboxed authenticated read and a `git push --dry-run`. Actual push/PR delivery remains unproven. No delegation or turn was started by this session.
4. Reconcile historical evaluation issues and milestones into the installation backlog without deleting evidence or marking unfinished work complete.
5. Add bounded log retention for the persistent service.

## Completed foundation

- GitHub fork created and cloned; upstream remote configured.
- Cyrus initiative created; Cyrus Installation project renamed, linked, and read back.
- `corepack pnpm install --frozen-lockfile` and `corepack pnpm build` pass; built CLI version check returns 0.2.72.
- Mac launchd chosen and installed; worker/tunnel startup and public idle/version verified.
- Expired access token renewed using the upstream Linear client and the existing refresh token; OAuth app and routes preserved.
- Launchd-context connection check passes, including a GitHub API read inside a Codex workspace-write sandbox; no model turns spent.
- Existing cloudflared binary copied into ignored local runtime storage; rollback backup preserved. Shell/plist/ingress validation passes.
- Automatic recovery verified after separate idle tunnel and worker terminations; unload/reload verified with no owned orphan processes.
- Unsigned public webhook rejected (401); existing app subscription cannot be listed without an admin role, so actual delegation delivery is not claimed.
- Model-free F1 startup, RPC health/status and local issue creation pass; test server stopped. [Protocol report](apps/f1/test-drives/2026-09-18-mac-installation.md) records the partial scope and existing source-CLI invocation issue.
- Routing updated through project-bootstrap's locked atomic writer, with backup: Arkanoid removed, Cyrus fork registered under cy-4244; both changes confirmed in the running worker's hot-reload log. Doctor passes with no hazards. Existing real project routes retained.
- Configured the Codex `gpt-5.6-sol` / `low` default with an atomic backup, taught the maintained fork to interpret existing friendly Linear model and effort labels, and verified schema export, full build/typecheck, focused tests, model-free runner config resolution, sandboxed authenticated push dry-run, and idle service restart. No SYS-18 session has started.

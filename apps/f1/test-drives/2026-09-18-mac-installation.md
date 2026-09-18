# Mac installation protocol check

**Date:** 2026-09-18
**Goal:** Validate source-build startup and local issue-tracker operations without model execution or live Linear writes.
**Test Repo:** `/tmp/cyrus-f1-mac-install-20260918`

## Verification results

- ✅ Built CLI initializes a fresh Git repository with main branch.
- ✅ F1 server starts on localhost:3600; RPC ping and status pass.
- ✅ Local issue creation returns `issue-1` / `DEF-1`; no live Linear issue created.
- ⬜ Agent session, worktree, activity rendering and full model pipeline are not exercised.

This is a partial, model-free F1 protocol check, not an end-to-end pass. Full session execution remains in PLAN.md for the next useful delegated task.

## Commands and observations

Use `node apps/f1/dist/src/cli.js` for init-test-repo, ping, status and create-issue. The documented source invocation through `bun apps/f1/src/cli.ts` fails because its package.json lookup resolves to `apps/package.json`. Using the compiled CLI avoids that existing source-invocation issue without changing upstream code. F1 server runs through the ignored repo-local `.runtime/runF1Acceptance.sh` foreground launcher and `.command` wrapper; it was stopped after the check.

## Separate live-service verification

- Source CLI 0.2.72 served through the existing public tunnel.
- Existing Linear refresh token renewed access; the agent remains Cyrus in mDo.
- Launchd-context credential check and Codex workspace-write GitHub read passed.
- Worker-exit and tunnel-exit automatic recovery each restored public idle status.
- Unsigned webhook rejected with HTTP 401. Listing the app's webhook subscription requires admin access, so actual Linear delegation delivery remains unverified.

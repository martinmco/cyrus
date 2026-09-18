import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";

async function main() {
	const config = JSON.parse(
		readFileSync(`${process.env.CYRUS_HOME}/config.json`, "utf8"),
	);
	for (const [id, workspace] of Object.entries(config.linearWorkspaces || {})) {
		const response = await fetch("https://api.linear.app/graphql", {
			method: "POST",
			headers: {
				Authorization: workspace.linearToken,
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				query:
					"query CyrusConnection { viewer { id name } organization { id name } }",
			}),
			signal: AbortSignal.timeout(15000),
		});
		const result = await response.json();
		if (!response.ok || result.errors || result.data?.organization?.id !== id) {
			throw new Error(
				`Linear connection failed for workspace ${id} (HTTP ${response.status})`,
			);
		}
		console.log(
			`Linear: ${result.data.organization.name}; agent ${result.data.viewer.name}; existing OAuth valid`,
		);
	}
	const response = await fetch("https://api.github.com/user", {
		headers: {
			Authorization: `Bearer ${process.env.GH_TOKEN}`,
			Accept: "application/vnd.github+json",
		},
		signal: AbortSignal.timeout(15000),
	});
	if (!response.ok)
		throw new Error(`GitHub token rejected (HTTP ${response.status})`);
	console.log(
		`GitHub: ${(await response.json()).login}; environment token accepted`,
	);
	if (process.env.CYRUS_CHECK_SANDBOX === "1") {
		const result = spawnSync(
			"/Users/martin/.local/bin/codex",
			[
				"sandbox",
				"-c",
				'sandbox_mode="workspace-write"',
				"-c",
				"sandbox_workspace_write.network_access=true",
				"/opt/homebrew/bin/gh",
				"api",
				"user",
				"--jq",
				".login",
			],
			{ encoding: "utf8", timeout: 30000, env: process.env },
		);
		if (result.status !== 0)
			throw new Error(`Sandbox GitHub read failed (exit ${result.status})`);
		console.log(
			`Codex workspace-write sandbox: environment token authenticates as ${result.stdout.trim()}`,
		);
	}
}
main().catch((error) => {
	console.error(error.message);
	process.exitCode = 1;
});

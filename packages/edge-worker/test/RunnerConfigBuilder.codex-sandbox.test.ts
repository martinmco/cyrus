import type {
	CyrusAgentSession,
	EdgeWorkerConfig,
	ILogger,
	RepositoryConfig,
} from "cyrus-core";
import { describe, expect, it } from "vitest";
import {
	type IChatToolResolver,
	type IMcpConfigProvider,
	type IRunnerSelector,
	RunnerConfigBuilder,
} from "../src/RunnerConfigBuilder.js";
import { RunnerSelectionService } from "../src/RunnerSelectionService.js";

const silentLogger: ILogger = {
	debug: () => {},
	info: () => {},
	warn: () => {},
	error: () => {},
} as unknown as ILogger;

function makeCodexBuilder(selector?: IRunnerSelector): RunnerConfigBuilder {
	const chatToolResolver: IChatToolResolver = {
		buildChatAllowedTools: () => ["Read(**)"],
	};
	const mcpConfigProvider: IMcpConfigProvider = {
		buildMcpConfig: () => ({}),
		buildMergedMcpConfigPath: () => undefined,
	};
	const runnerSelector: IRunnerSelector = {
		determineRunnerSelection: () => ({ runnerType: "codex" as const }),
		getDefaultModelForRunner: () => "gpt-5.5",
		getDefaultFallbackModelForRunner: () => "gpt-5.4",
	};
	return new RunnerConfigBuilder(
		chatToolResolver,
		mcpConfigProvider,
		selector ?? runnerSelector,
	);
}

function makeSession(): CyrusAgentSession {
	return {
		issueId: "issue-1",
		issue: { identifier: "ABC-1" },
		workspace: { path: "/ws/root", isGitWorktree: true },
	} as unknown as CyrusAgentSession;
}

function buildCodexConfig(
	sandboxSettings?: Record<string, unknown>,
	selector?: IRunnerSelector,
) {
	const { config } = makeCodexBuilder(selector).buildIssueConfig({
		session: makeSession(),
		repository: {
			id: "repo-a",
			name: "Repo A",
			repositoryPath: "/repos/repo-a",
			allowedTools: [],
		} as unknown as RepositoryConfig,
		sessionId: "sess-1",
		systemPrompt: "test",
		allowedTools: ["Read(**)"],
		allowedDirectories: ["/ws/root", "/repos/repo-a"],
		disallowedTools: [],
		cyrusHome: "/tmp/cyrus-home",
		linearWorkspaceId: "ws-1",
		logger: silentLogger,
		onMessage: () => {},
		onError: () => {},
		requireLinearWorkspaceId: () => "ws-1",
		...(sandboxSettings ? { sandboxSettings } : {}),
	});
	return config as {
		sandboxSettings?: { allowWrite?: string[]; allowRead?: string[] };
	};
}

describe("RunnerConfigBuilder Codex sandbox plumbing", () => {
	it("passes the selected low reasoning effort into the Codex runner", () => {
		const selector = new RunnerSelectionService({
			defaultRunner: "codex",
			codexDefaultModel: "gpt-5.6-sol",
			codexDefaultReasoningEffort: "low",
		} as EdgeWorkerConfig);
		const config = buildCodexConfig(undefined, selector) as unknown as Record<
			string,
			unknown
		>;
		expect(config.model).toBe("gpt-5.6-sol");
		expect(config.modelReasoningEffort).toBe("low");
	});
	it("translates the egress sandbox into a Codex filesystem allow-list", () => {
		// Plumbs both write (worktree) and read (worktree + allowed dirs) roots;
		// the Codex runner turns these into a per-thread permission profile.
		const config = buildCodexConfig({ enabled: true });
		expect(config.sandboxSettings).toEqual({
			allowWrite: ["/ws/root"],
			allowRead: ["/ws/root", "/ws/root", "/repos/repo-a"],
		});
	});

	it("leaves Codex sandbox settings unset when the egress sandbox is disabled", () => {
		expect(buildCodexConfig(undefined).sandboxSettings).toBeUndefined();
	});
});

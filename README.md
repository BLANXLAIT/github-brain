# github-brain

A GitHub App backed by a [Claude Managed Agent](https://platform.claude.com/docs/en/managed-agents/overview).

The App receives webhooks; a Lambda in AWS verifies them and starts a Managed Agent session; the agent then acts on the repo using the App's own installation tokens.

## Architecture

```
GitHub event
     │
     ▼  (App-signed webhook)
API Gateway ──▶ Lambda (HMAC verify + event filter)
                   │
                   ▼
           Managed Agent session
                   │
                   ├── mint installation token (as the App)
                   ├── gh CLI + Octokit
                   └── Open Brain memory
```

## Status

Ship #1 in progress: **Dependabot patch auto-merge** on `niemesrw/openbrain`.
Scope is deliberately tiny — one repo, one event shape — so the architecture gets proven before scope widens.

Later ships (not yet built):
- Event-driven issue triage + PR review
- Repo bootstrapping PRs (missing `claude.yml` / `CLAUDE.md`)
- Release notes drafting

## Layout

```
cdk/       CDK stack: API Gateway + Lambda webhook receiver
agent/     Managed Agent system prompt + tool definitions
.github/   Deploy workflow (OIDC → AI account)
```

## Accounts

Deploys to the `blanxlait-ai` AWS account (`057122451218`, `us-east-1`).

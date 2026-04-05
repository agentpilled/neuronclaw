# Changelog

All notable changes to NeuronClaw will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-04-05

### Added
- Proactive skill matching — agent searches for existing skills before starting a task
- Multi-perspective review — evaluates security, clarity, generalization, and maintainability before promotion
- Skill forking — create variant skills without touching the original (`references/forking.md`)
- Composable skills — skills can reference other skills as sub-steps (`references/composability.md`)
- Adaptive thresholds — GC auto-tunes draft expiry, stable expiry, and quality thresholds from usage patterns
- Optional approval gates — `approval_mode: manual` in config.yaml for user confirmation before promotion
- Prerequisites declaration in SKILL.md frontmatter with install guidance
- Progressive first-run onboarding with actionable error messages
- Duration and tool count tracking per skill execution
- Richer metadata: `avg_duration_seconds`, `avg_tool_count`, `forked_from`, `depends_on`

## [1.0.0] - 2026-04-05

### Added
- Initial release
- Core skill lifecycle: detection, drafting, promotion, self-patching
- Anti-bloat draft-to-skill pipeline with probation system
- Quality scoring with weighted formula (success rate, frequency, recency)
- Garbage collection with on-demand and cron modes
- Skill consolidation via semantic similarity search
- Security scanner covering 5 threat categories
- Full template and example library
- Community documentation and walkthrough

# Before & After: Data Pipeline Setup

## Before NeuronClaw

The user periodically asks to set up data pipelines: CSV ingestion into
Postgres, API polling jobs, cron-scheduled ETL scripts.

Each time:
1. Agent writes a fresh script
2. Forgets the connection pooling configuration that prevents connection leaks
3. Doesn't add error handling for network timeouts (discovered the hard way last time)
4. Doesn't set up proper logging until the user asks
5. Misses the cron syntax for the specific schedule pattern

**Hard-won knowledge from each pipeline evaporates between sessions.**

## After NeuronClaw

**Pipeline 1:** Agent sets up a CSV-to-Postgres ingestion. Complex: 8 tool
calls, connection pool debugging. NeuronClaw captures a draft: `setup-data-pipeline-postgres`.

**Pipeline 2:** Agent sets up an API polling job into the same Postgres DB.
`qmd` finds the draft (75% overlap — same DB connection, similar error
handling). NeuronClaw increments match_count, adds API-specific steps, promotes
to a skill.

**Pipeline 3:** Agent loads the skill. Connection pooling is configured
correctly on the first try. Error handling for timeouts is included. Cron
syntax is specified in the troubleshooting section.

**Pipeline 4:** Same skill, but the user needs a different schedule pattern.
Agent discovers the cron section is incomplete. Self-patches to add more
schedule examples. Future pipelines benefit.

## The Value

The **connection pool configuration** alone was worth the skill. It took 30
minutes to debug the first time. With the skill, it's a copy-paste from the
procedure section.

The **error handling patterns** accumulated over 3 pipeline setups. No single
pipeline taught all the edge cases — the skill consolidated knowledge from
multiple sessions.

| Metric | Before | After |
|--------|--------|-------|
| Connection pool issues | Every time | Never (in the skill) |
| Missing error handling | Usually | Included from day 1 |
| Setup time | 30–45 min | 15 min |
| Cron syntax debugging | Frequent | Documented |

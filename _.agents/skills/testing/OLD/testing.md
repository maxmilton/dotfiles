---
paths:
  - "**/*.{test,spec}.ts"
---

# Testing

Apply when adding, changing, deleting, or reviewing tests. Imperatives and **never** are required;
**prefer** is the default; **may** and named exceptions permit departures.

**Goal: a red test that says what broke without opening the file.**

Consult Memories for case-specific evidence; re-measure
constraints after relevant runtime or tool changes. Background: `testing.sources.md`.

If using `expectTypeOf`, also read `~/.claude/docs/expect-type.md`.

## Choose what and where to test

- **S1 — Test valuable behaviour.** The test must fail for a reason we care about. Weigh confidence
  against runtime, comprehension, and maintenance cost. Do not keep a case solely for coverage or
  because it blocks a refactor.
- **S2 — Use an independent oracle.** Prefer an external result, known example, reference
  implementation, real dependency, or independently derived property. A round trip alone proves
  consistency, not correctness.
- **S3 — Run real dependencies** in isolated local fixtures, never production or shared state. Mock
  only when a dependency is unavailable, unaffordable, or cannot fail deterministically. Do not mock
  a contract already tested against the real system.

## Structure and verify tests

- **R1 — Test one behaviour.** Split independently failing outcomes, not individual assertions.
  Supporting assertions may guard the main assertion or form a symmetric pair.
- **R2 — Name the failure.** Name scenario and outcome; let `describe` carry the subject. Treat “and”
  as a warning: split clauses that can fail independently, but keep an indivisible integration outcome.
- **R3 — Assert observable contracts narrowly.** Test public behaviour, not private calls, source
  shape, or incidental sequence unless promised. Assert only promised fields, order, and effects;
  allow at most one full-equality case for a complex object's common contract.
- **R4 — Match fixture to subject.** Use the cheapest faithful fixture when tiers observe the same
  behaviour. Pure logic uses properties over reproducible inputs without launching anything. Browser
  behaviour uses real headless Chrome; installed package or CLI behaviour uses the E2E fixture. Put
  browser cases that must damage Chrome in a `-crash` file; otherwise group by subject. Do not target a test-tier
  ratio. Measure the slowest fixture before rejecting a split as too expensive.
- **R5 — Own fixture state.** Keep setup in its test; no test depends on a sibling's state. A hook may
  provision an explicit, expensive baseline that tests read or derive private mutable state from,
  but never observe sibling mutations. Keep provisioning under test local and do not reuse its result.
  Control and restore ambient clocks, randomness, environment, locale, paths, and ports. Global state
  requires sequential, exclusive access and a record of which test uses it.
- **R6 — Keep helpers and teardown local.** Keep one-case values local. A file helper needs several
  callers *and* a readability gain. Prefer `using` or `await using`; close explicitly only when close
  is under test, disposal would hang, or scope lifetime would change a measurement.
- **R7 — Isolate timing.** Give timing its own test and a generous bound that separates two
  explanations named in a comment; the bound is not a performance target. Test deadline correctness
  and promptness separately. Replace flaky sleeps with synchronization, preferably a round trip
  proving the awaited state. Keep a bounded wait only when something must never arrive, and explain
  why synchronization cannot replace it.
- **R8 — Count assertions.** Every test calls `expect.assertions(n)`. Use `n = 0` for a grouped `types`
  test; keep one such test per `describe`.
- **R9 — Preserve why.** Delete comments that restate code. Keep comments only for rationale or
  evidence code cannot express: oracle or fixture choice, false-positive guard, measurement,
  provenance, timing, synchronization, external behaviour, or tool/runtime constraint. Lint directives
  and required `@ts-expect-error` explanations are exempt. Write
  `Measured <runtime, tool, or system and version>: <invariant>` without a date; keep the result and
  reason beside its assertion, and move the comment with the assertion. When provenance matters,
  mark **regression** (pre-fix behaviour), **characterization** (external behaviour), or **accepted
  tradeoff**; do not invent provenance for a specification case. Record unavoidable sleeps,
  global-state assumptions, and critically useful mutation results to memory.
- **R10 — Protect and prove the oracle.** Never weaken, delete, skip, or rewrite a valid oracle to
  obtain green. Change it only for a changed contract or disproved oracle, and record why. A regression
  must be red on pre-fix code or a targeted mutation before green is accepted. For a non-trivial split
  or suspicious overlap, mutate one behaviour in a temporary git worktree; only its named tests
  should fail. Revert before the next mutation. If many independently named tests fail, assume
  coupling unless a documented exception applies. Mutation is targeted, not required for every case.
  Exceptions: turn a hang into a bounded red; guard dangerous PIDs or paths before acting; removing
  a shared awaited mechanism may fail a whole block; type-shape mutations may fail only under
  `bun run lint:ts`; tests sharing one public error string may fail together.

## Bun, TypeScript, and coverage constraints

- Never `await` a `.resolves` or `.rejects` matcher in this setup.
- For `toHaveParameters`, account for `Function.length`: optional parameters count through the first
  default; `f(a, b?, c = 1)` has two required and one optional parameter.
- `Bun.spawn` child code is excluded from coverage. The uncovered-line column can miss callbacks on
  executed lines; use `% Funcs` or lcov's `FNF`/`FNH`.

## Test file layout

```text
test/unit/<subject>.test.ts         subject behaviour in isolation
test/unit/<subject>-api.test.ts     subject's published runtime and type surface
test/unit/<subject>-crash.test.ts   same system with destructive setup
test/unit/<subject>-<pure>.test.ts  extracted pure logic and its own shape
test/e2e/<name>.spec.ts             installed package and CLI
test/setup.ts                       preload; registers matchers such as toHaveParameters
```

---
paths:
  - "**/*.{test,spec}.ts"
  - "test/**"
---

# Testing

Project instructions win on conflict; propose before deviating.
Goal: a test fails exactly when promised behaviour breaks, and its output alone says what broke.

## What to test
- Test only relied-on behaviour (failure paths included) worth its runtime and upkeep; coverage alone justifies nothing.
- Test validation at trust boundaries; beyond them, never test impossible states.
- Take expectations from outside the code under test (spec, known example, reference implementation, property), never by running, mirroring, or snapshotting it; a round trip proves only consistency.
- Use real dependencies in isolated local fixtures, never production or shared state; mock only what's unavailable, unaffordable, or can't fail on demand, reproducing observed behaviour.
- Prefer a characterization test to a comment for version-sensitive external behaviour you rely on; every upgrade then re-checks it.
- Use the cheapest fixture that sees the real behaviour: pure logic gets examples and seeded properties, launching nothing; browser behaviour gets real headless Chrome; packages and CLIs run installed (E2E).

## Writing
- One behaviour per test: split outcomes that can fail independently; extra assertions only guard the main one or complete a symmetric pair. Measure setup cost before citing it to merge tests.
- Name scenario and outcome; `describe` names the subject. An "and" means two tests unless the outcome is indivisible.
- Assert only promised results, fields, order, and effects, never private calls, source shape, or incidental sequence; use full equality at most once per complex object, on its common case.
- Every test calls `expect.assertions(n)`; type checks share one `types` test per `describe`, with `n = 0`. Read `~/.claude/docs/expect-type.md` before using `expectTypeOf`.
- Inline single-use values; a helper needs several callers and a readability gain.
- Comment only what a reader might wrongly "fix" (a deliberate wait or bound, a `test.serial` mark, an unusual oracle or fixture, a false-positive guard), in one line, with the version only if the reason is version-specific; never restate code.
- Label non-specification tests as regression, characterization, or accepted tradeoff; never invent a label.

## State and timing
- Each test owns its state and passes alone and under `--randomize`. Hooks may share an expensive baseline that tests only read or derive private state from; tests that damage it or exercise its provisioning set up their own.
- Pin and restore ambient state (clock, RNG, env, locale, cwd); use temp dirs and port 0. Tests that mutate process-global state are `test.serial`.
- Clean up with `using`/`await using` and leave nothing running; close explicitly only when closing is under test, disposal would hang, or scope lifetime would skew a measurement.
- Never sleep for state; synchronize on it, ideally with a round trip that proves it. Sleep only to show something never arrives.
- Timing gets its own test and a loose bound that separates two named explanations; it isn't a performance target. Test deadline correctness and promptness separately.
- A flake is a bug: fix the race, never retry it, and prove the fix with `--rerun-each`.

## Proving
- Never weaken or game tests: no `.skip`, `.todo`, `.failing`, `.only`, loosened matchers or bounds, deleted cases, or code special-cased for test inputs.
- Change an expectation only for a changed contract or independent evidence it's wrong, cited beside it and flagged in your summary.
- If a test can't pass legitimately, stop and report why and what you tried; that's a valid outcome, not a failure.
- A bug fix's failing test must fail on the pre-fix code (or, if that's gone, a mutation reverting the fix) at an assertion that shows the bug.
- Check non-trivial test splits and suspected overlap with one mutation at a time, in a scratch copy that includes uncommitted changes; only that behaviour's tests should fail. Wider failure means coupling unless the mutated code is genuinely shared; type-level mutations fail the typecheck, not tests.
- If a mutation hangs a test, bound the awaited step so it fails naming what never arrived. Before mutating code that signals PIDs or deletes paths, guard the targets.

---
paths:
  - "**/testing.sources.md"
---

# Testing background

Non-normative rationale and examples for `testing.md`. The operative requirements and exceptions
remain in that rule.

## Why the rules exist

- **Goal:** A red test should say what broke without opening the file. This draws on Beck's
  *Specific* and Meszaros' *Defect Localization*.
- **S1:** Coverage identifies unexecuted code, not valuable tests. A test retained only to block
  refactoring can cost more than the confidence it supplies.
- **S2:** Implementation-derived oracles can repeat the implementation's mistake.
  `decode(encode(x)) === x` demonstrates internal consistency, not correctness against an independent
  contract.
- **S3:** Mocks record our beliefs about dependencies; they can miss defects in the real contract.
- **R1:** A failed assertion hides later assertions. A supporting assertion can prove a directory
  existed before testing its removal; a symmetric pair can prove both concurrent clients respond.
- **R2:** `locks the user out after three invalid logins` names a scenario and outcome more clearly
  than `isUserLockedOut_invalidLogin`. “And” is a clue to independent outcomes, not a literal ban.
- **R3:** A broad fixture does not justify broad assertions.
- **R6:** Repetition or renaming alone does not justify a helper.
- **R7:** A timing bound distinguishes causal explanations rather than setting a performance target.
  For example: `1500ms distinguishes Browser.close from the 2s kill-timeout escalation`.
- **R8:** `expectTypeOf` is erased at runtime, so a `types` test counts zero runtime assertions.
  TypeScript reports each failing line in a grouped type test.
- **R10:** Green alone does not prove failure specificity. A targeted mutation reveals whether the
  named test detects the intended behaviour; failure of many unrelated tests may reveal coupling.

## Runtime observations

- In the measured Bun setup, `.resolves` and `.rejects` matchers return `undefined`; `await` does
  nothing and triggers oxlint's `typescript(await-thenable)`. Bun holds the test open until the promise
  settles, then `await using` disposal runs. Bun's documentation shows contrary code samples;
  re-measure after relevant Bun or tooling changes.

## Sources

- Kent Beck, [*Test Desiderata*](https://testdesiderata.com/)
- Gerard Meszaros, [*xUnit Test Patterns*](http://xunitpatterns.com/)
- Andrew Trenk, [“Writing Descriptive Test Names”](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html)
- Kai Kent, [“Prefer Narrow Assertions in Unit Tests”](https://testing.googleblog.com/2024/04/prefer-narrow-assertions-in-unit-tests.html)
- *Software Engineering at Google*, [“Testing Overview”](https://abseil.io/resources/swe-book/html/ch11.html)
- Andrew Trenk, [“Test Behavior, Not Implementation”](https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html)
- Kent C. Dodds, [“The Testing Trophy and Testing Classifications”](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
- Anthropic, [“Best practices for Claude Code”](https://code.claude.com/docs/en/best-practices)

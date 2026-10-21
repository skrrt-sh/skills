---
name: testing
description: Decide which tests to write, keep, and delete, and prove a change works before calling it done. Test only business logic and its corner cases. Run the real thing on every target before reporting a fix. Delete tests for removed or replaced behavior. Use when writing, adding, reviewing, or cleaning up tests or specs, when fixing a bug or a flaky test, before reporting any change as done, or when a change removes or replaces behavior that tests cover.
---

# Testing

A test exists only to guard business logic that could break unnoticed.

## Write

- Test business logic: domain rules, calculations, state transitions, decisions.
- Cover its corner cases: boundaries, empty or missing input, invalid states, ordering, failure
  paths.
- Test through the public interface. A refactor must not break a test.
- A bug fix gets one test that asserts the invariant the bug broke, such as "a refund never exceeds
  the charge". Never assert an incidental output of the fix.

## Fix

- Fix a bug test-first: write the failing test, then the fix.
- Fix a flaky test at its root cause, such as with a fake clock. Never raise timeouts or loosen
  bounds. Then run it 20 times in a row.

## Do not write

- Tests for third-party libraries, the framework, or the language.
- Tests for internals: private helpers, wiring, implementation steps.
- Tests for obvious code: getters, setters, constructors, code without branches, and mappers or
  DTO conversions, including field selection, renaming, and standard formatting.
- Assertions about a library call's result: that it is set, differs from the input, or has a
  format. Assert only your code's decision around the call. Stub the library when it is slow or
  nondeterministic.
- Unit tests of thin I/O adapters against hand-made fakes of the library they wrap.
- A test for a rule an existing test already covers. Extend that test instead.

When asked to test a unit, end the reply with one line naming what you left untested and why.

## Verify

Before reporting anything as done or fixed:

- Run it for real on every platform it ships to, as every role the flow touches, such as guest
  and signed-in: simulators, a headless browser, staging, or a local stack.
- Check the original bug is gone and nothing that worked before broke.
- When login, onboarding, or missing data blocks the check, create a test account or seed data
  yourself. When no headless browser or simulator is installed, install one, such as Playwright.
- Before telling the user to change their setup, reproduce the failure and prove the cause.
- When speed or resource use is a goal, measure before and after and report the numbers.
- Keep the check loop short: script a harness instead of manual walkthroughs.
- Wait on an event, log line, or exit, never a fixed sleep. Kill jobs that stop making progress.
- Stop old instances first. Use your own headless devices; never one the user or another agent
  holds, and never the user's mouse or screen unless they ask. Shut down what you started.
- Report what you ran and what you saw. Unverified means not done.

## Clean up

In every change that removes or replaces behavior:

- Delete tests for the removed behavior.
- Rewrite tests that assert the old behavior to assert the new one. Never keep both.
- Delete fixtures, mocks, and helpers left unused.
- In test files you touch, delete tests that match "Do not write".
- Never delete or weaken a test to make a failing check pass. Fix the code or report the failure.

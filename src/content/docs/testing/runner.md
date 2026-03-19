---
title: The fe test Runner
description: Running tests with the Fe CLI
---

The `fe test` command discovers, compiles, and runs all `#[test]` functions.

## Basic Usage

Run all tests in a file:

```bash
fe test my_contract.fe
```

Run all tests in an ingot (directory with `fe.toml`):

```bash
fe test path/to/my-ingot/
```

Run tests matching a pattern:

```bash
fe test --filter transfer my_contract.fe
```

## Filtering Tests

The `--filter` option matches against test function names. Only tests containing the filter string run:

```bash
# Run only tests with "balance" in the name
fe test --filter balance my_contract.fe

# Run only tests with "overflow" in the name
fe test --filter overflow my_contract.fe
```

## Parallelism

Tests run in parallel by default (8 workers). Control this with `--jobs`:

```bash
# Run tests sequentially
fe test --jobs 1 my_contract.fe

# Use 16 parallel workers
fe test --jobs 16 my_contract.fe
```

## Glob Patterns

Test multiple files at once using glob patterns:

```bash
# All .fe files in a directory
fe test "tests/*.fe"

# All test files recursively
fe test "src/**/*.fe"
```

## Workspace Testing

In a workspace with multiple ingots, test a specific member:

```bash
# Test a specific ingot by name
fe test --ingot my-lib path/to/workspace/
```

## Debugging Options

### Event Logs

Show events emitted during test execution:

```bash
fe test --show-logs my_contract.fe
```

### EVM Traces

Trace EVM opcodes for debugging:

```bash
fe test --trace-evm my_contract.fe
```

### Call Traces

Show the call trace for each test:

```bash
fe test --call-trace my_contract.fe
```

## Output Format

A typical test run looks like:

```
PASS  [0.0003s] test_max
PASS  [0.0003s] test_clamp
PASS  [0.0004s] test_counter_contract
FAIL  [0.0003s] test_broken
    Test reverted: 0x

test result: FAILED. 3 passed; 1 failed

failures:
    test_broken
```

- **PASS** — Test function completed without reverting
- **FAIL** — Test function reverted (or succeeded when `should_revert` was expected)
- The time shown is execution time, not compilation time

## Summary of CLI Options

| Option | Description |
|--------|-------------|
| `--filter PATTERN` | Only run tests matching pattern |
| `--jobs N` | Parallel worker count (default: 8) |
| `--show-logs` | Display emitted event logs |
| `--trace-evm` | Trace EVM opcodes |
| `--call-trace` | Print call traces |
| `--ingot NAME` | Test specific workspace member |
| `--backend yul\|sonatina` | Codegen backend (default: sonatina) |
| `--optimize 0\|s\|2` | Optimization level |

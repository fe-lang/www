# Change: Add Events & Logging Documentation

## Why
Part 10 of The Fe Guide covers events and logging—Fe's mechanism for recording on-chain activity that external systems can observe. Events are essential for building dApps that react to contract state changes, and Fe's explicit Log effect makes event emission a tracked capability.

## What Changes
- Document event struct definition with `#[indexed]` fields
- Document emitting events with `log.emit()`
- Document the Log effect and why logging is explicit
- Document ABI compatibility with EVM logs

## Impact
- Affected specs: `documentation`
- Affected code: `src/content/docs/events/*.md` (4 files, replacing placeholder content)
- Dependencies: Part 5 (Effects) provides foundation for Log effect understanding

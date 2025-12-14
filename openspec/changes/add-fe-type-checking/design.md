## Context

The Fe Guide documentation contains numerous code examples that should be valid Fe code. Without automated checking, examples can become stale or contain errors as the language evolves. Since Fe is not yet released, there's no official binary distribution to download.

**Stakeholders:**
- Documentation authors (need fast feedback)
- Learners (need working examples)
- Fe language maintainers (need to know when language changes break docs)

**Constraints:**
- Fe has no official releases yet (no downloadable binaries)
- Multi-platform support is desirable but not critical initially
- Some code blocks are intentional snippets, not complete programs

## Goals / Non-Goals

**Goals:**
- Catch broken code examples before they reach readers
- Provide fast local feedback for documentation authors
- Automate checking in CI to prevent regressions
- Support both complete examples and intentional snippets

**Non-Goals:**
- Multi-platform binary support (Linux-first is acceptable)
- Runtime testing of examples (type checking only)
- Automatic fixing of broken examples

## Decisions

### Decision: Commit Linux binary to repository
**What:** Store a pre-built `fe` binary for Linux x86_64 directly in the repository.

**Source:** Copy from local Fe build at `~/Documents/hacking/ef/fe/target/release/fe`

**Why:**
- Simplest approach given no official Fe releases
- Works immediately for CI (Linux runners)
- Works for Linux developers locally
- No external dependencies or network requirements

**Alternatives considered:**
- Build from source: Requires Rust toolchain, slower
- Docker: Additional dependency, more complex
- Download from CI artifacts: Requires fe repo changes, fragile

### Decision: Use `ignore` annotation for snippets
**What:** Code blocks marked ` ```fe ignore ` are skipped during type checking.

**Why:**
- Simple, explicit opt-out
- Visible in source (documentation intent is clear)
- Compatible with existing markdown tooling
- No complex heuristics needed

**Alternatives considered:**
- Wrapper templates: More complex, deferred to Phase 3
- Separate file extension (`.fe-snippet`): Doesn't work in markdown
- Automatic detection: Too fragile, false positives/negatives

### Decision: Shell script for extraction and checking
**What:** Use bash scripts for the core tooling.

**Why:**
- No additional dependencies beyond standard Unix tools
- Simple to understand and modify
- Works in CI without setup
- `grep`, `sed`, `awk` are sufficient for markdown parsing

**Alternatives considered:**
- Node.js script: More dependencies, but better parsing
- Dedicated tool (mdbook-like): Over-engineered for this use case

### Decision: Error output maps to markdown source
**What:** Errors reference the original markdown file and line, not the extracted temp file.

**Why:**
- Authors can immediately find and fix issues
- Integrates well with IDE "click to navigate"
- CI annotations can point to correct location

## Directory Structure

```
the-guide/
├── bin/
│   └── fe-linux-x86_64      # Pre-built Fe binary
├── scripts/
│   ├── fe                    # Wrapper script (platform detection)
│   ├── extract-fe-blocks.sh  # Extract code blocks from markdown
│   └── check-examples.sh     # Main entry point
├── .github/
│   └── workflows/
│       └── check-examples.yml
└── package.json              # npm scripts: check:examples
```

## Code Block Extraction Algorithm

```
1. Find all .md files in src/content/docs/
2. For each file:
   a. Scan for lines matching ```fe (but not ```fe ignore)
   b. Record start line number
   c. Capture content until closing ```
   d. Write to temp file: {hash}_{file}_{line}.fe
3. Return list of temp files with source mappings
```

## Error Mapping Strategy

When `fe check` reports an error like:
```
/tmp/examples/abc123_erc20_42.fe:5:10: error: unknown type `u257`
```

Transform to:
```
src/content/docs/examples/erc20.md:46:10: error: unknown type `u257`
```

(Line 46 = code block start line 42 + error line 5 - 1)

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Binary becomes stale | Document update process, consider automation |
| Git repo bloat from binary | Use Git LFS if binary > 10MB |
| Non-Linux developers can't check locally | Clear skip message, CI catches issues |
| Snippets incorrectly marked as complete | Phase 2 audit, contributor guidelines |
| Fe language changes break many examples | Run checker before Fe releases, batch fix |

## Migration Plan

1. **Phase 1**: Infrastructure + Examples directory only
   - Add binary, scripts, CI
   - Verify against known-good ERC20 example
   - Fix any issues in examples/

2. **Phase 2**: Full documentation coverage
   - Run against all docs
   - Add `ignore` to intentional snippets
   - Fix broken complete examples

3. **Phase 3** (optional): Wrapper templates
   - Add support for `wrap=function` etc.
   - Convert applicable snippets to checked

## Resolved Questions

1. **Binary updates**: Manual process for now. No automation needed initially.

2. **Git LFS**: Not needed. Binary will be committed directly to the repository.

3. **Partial checking**: Yes, support checking individual files for faster iteration:
   - `npm run check:examples -- path/to/file.md`
   - Useful during documentation writing

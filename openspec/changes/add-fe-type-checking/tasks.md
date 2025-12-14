# Tasks: Add Fe Type Checking for Documentation Examples

## 1. Binary Distribution Setup
- [x] 1.1 Create `bin/` directory structure
- [x] 1.2 Copy fe binary from `~/Documents/hacking/ef/fe/target/release/fe` to `bin/fe-linux-x86_64`
- [x] 1.3 Add binary to repository
- [x] 1.4 Create `scripts/fe` wrapper script for platform detection
- [x] 1.5 Document binary update process in CONTRIBUTING.md or similar

## 2. Code Block Extraction
- [x] 2.1 Create `scripts/extract-fe-blocks.sh` (or Node.js equivalent)
- [x] 2.2 Parse markdown files for ` ```fe ` code blocks
- [x] 2.3 Support `ignore` annotation to skip blocks
- [x] 2.4 Extract blocks to temp directory as `.fe` files
- [x] 2.5 Preserve source file and line number in output filename or metadata
- [x] 2.6 Handle edge cases (nested blocks, frontmatter, etc.)

## 3. Type Checking Script
- [x] 3.1 Create `scripts/check-examples.sh` main entry point
- [x] 3.2 Call extraction script to get `.fe` files
- [x] 3.3 Run `fe check` on extracted files
- [x] 3.4 Parse fe output and map errors back to markdown source
- [x] 3.5 Format error output for readability (file:line: error)
- [x] 3.6 Return appropriate exit codes (0 = pass, 1 = fail)

## 4. npm Integration
- [x] 4.1 Add `check:examples` script to package.json
- [x] 4.2 Add `check:examples:verbose` for detailed output
- [x] 4.3 Support partial checking: `npm run check:examples -- path/to/file.md`
- [x] 4.4 Document usage in README or CONTRIBUTING

## 5. GitHub Action
- [x] 5.1 Create `.github/workflows/check-examples.yml`
- [x] 5.2 Trigger on PR and push to main
- [x] 5.3 Run check script and fail on errors
- [ ] 5.4 Annotate PR with error locations if possible (deferred)
- [ ] 5.5 Cache any dependencies for faster runs (not needed)

## 6. Documentation Audit (Phase 1 - Examples)
- [x] 6.1 Run checker on `src/content/docs/examples/`
- [x] 6.2 Fix any broken examples found
- [x] 6.3 Verify ERC20 example passes (known good reference)

## 7. Documentation Audit (Phase 2 - All Docs)
- [x] 7.1 Run checker on all documentation
- [x] 7.2 Identify snippets that need `ignore` annotation
- [x] 7.3 Add `ignore` to intentional snippets
- [x] 7.4 Fix any broken complete examples
- [x] 7.5 Update documentation style guide with code block conventions

## 8. Testing
- [x] 8.1 Test local workflow on Linux
- [ ] 8.2 Test CI workflow with intentional failure (requires PR)
- [ ] 8.3 Test CI workflow with all passing (requires PR)
- [x] 8.4 Verify helpful error messages for non-Linux platforms
- [x] 8.5 Test with edge cases (empty blocks, special characters, etc.)

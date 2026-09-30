# Generated API documentation

Do not hand-edit `docs.json`, `index.html`, `fe-web.js`, or the generated styles. Regenerate with:

```bash
bash scripts/generate-docs.sh
```

The generator uses the release pinned in `.fe-version`. It downloads the binary through `scripts/fe` and clones the matching release sources into `bin/` as needed. Git and Node.js are required; building the compiler is not required.

To reuse a release binary and an unmodified checkout at the same tag:

```bash
FE_BIN=/path/to/fe FE_REPO=/path/to/fe-source bash scripts/generate-docs.sh
```

The generated API includes builtin library sources and landing-page SCIP data. Source locations are resolved against the release checkout and displayed inline.

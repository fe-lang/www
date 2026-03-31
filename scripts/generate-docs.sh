#!/bin/bash
set -euo pipefail

# Generate docs.json with stdlib + landing page SCIP data.
# Requires: fe CLI on PATH

FE_BIN="${FE_BIN:-fe}"
FE_REPO="${FE_REPO:-../fe}"
OUTDIR="public/docs"

echo "Generating stdlib docs (split output)..."
"$FE_BIN" doc --builtins -o "$OUTDIR" "$FE_REPO/ingots/std" static

echo "Merging landing page SCIP..."
"$FE_BIN" doc src/examples/landing-page.fe json --merge "$OUTDIR/docs.json"

echo "Done."
echo "Output: $OUTDIR/{docs.json, index.html, fe-web.js, fe-highlight.css}"

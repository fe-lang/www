#!/bin/bash
set -euo pipefail

# Generate docs.json with stdlib + landing page SCIP data.
# Requires: fe CLI on PATH, python3

FE_BIN="${FE_BIN:-fe}"
FE_REPO="${FE_REPO:-../fe}"
OUTDIR="public/docs"

echo "Generating stdlib docs..."
"$FE_BIN" doc --builtins -o /tmp/fe-www-stdlib "$FE_REPO/ingots/std" json

echo "Generating landing page SCIP..."
"$FE_BIN" doc -o /tmp/fe-www-landing src/examples/landing-page.fe json

echo "Generating static viewer..."
"$FE_BIN" doc --builtins -o "$OUTDIR" "$FE_REPO/ingots/std" static

echo "Merging docs.json..."
python3 -c "
import json

with open('/tmp/fe-www-stdlib/docs.json') as f:
    stdlib = json.load(f)
with open('/tmp/fe-www-landing/docs.json') as f:
    landing = json.load(f)

stdlib['index']['items'].extend(landing['index']['items'])
stdlib['index']['modules'].extend(landing['index']['modules'])

if landing.get('scip'):
    for sym, info in landing['scip']['symbols'].items():
        if sym not in stdlib['scip']['symbols']:
            stdlib['scip']['symbols'][sym] = info
        else:
            existing = stdlib['scip']['symbols'][sym]
            if not existing.get('doc_url') and info.get('doc_url'):
                existing['doc_url'] = info['doc_url']
    landing_files = landing['scip']['files']
    if '' in landing_files:
        landing_files['landing-page.fe'] = landing_files.pop('')
    stdlib['scip']['files'].update(landing_files)

with open('$OUTDIR/docs.json', 'w') as f:
    json.dump(stdlib, f)
print('Done.')
"

echo "Generated: $OUTDIR/index.html + $OUTDIR/docs.json"
echo "Theme overrides applied via src/pages/docs/index.astro + public/docs/theme.css"

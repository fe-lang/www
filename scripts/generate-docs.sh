#!/bin/bash
set -euo pipefail

# Generate with the release compiler and its matching builtin sources.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."
FE_BIN="${FE_BIN:-./scripts/fe}"
FE_TAG="$(tr -d '[:space:]' < .fe-version)"
FE_REPO="${FE_REPO:-bin/fe-source-$FE_TAG}"
OUTDIR="public/docs"
if [[ ! -d "$FE_REPO" ]]; then
    git clone --depth 1 --branch "$FE_TAG" https://github.com/argotorg/fe.git "$FE_REPO"
fi
if [[ "$(git -C "$FE_REPO" rev-parse HEAD)" != "$(git -C "$FE_REPO" rev-parse "$FE_TAG^{commit}")" ]] ||
   [[ -n "$(git -C "$FE_REPO" status --porcelain --untracked-files=no -- ingots)" ]]; then
    echo "FE_REPO must contain unmodified builtin sources at $FE_TAG" >&2
    exit 1
fi
if [[ "$("$FE_BIN" --version)" != "fe ${FE_TAG#v} "* ]]; then
    echo "API generation requires the $FE_TAG compiler" >&2
    exit 1
fi

echo "Generating builtin library docs and landing page SCIP..."
# Loading std as an ordinary ingot triggers reserved effect-handle diagnostics
# in released compilers. Extract the compiler's actual builtins through a user entrypoint.
"$FE_BIN" doc --builtins -o "$OUTDIR" src/examples/landing-page.fe static

# Builtin source locations contain basenames. Resolve them against the matching
# release checkout. The viewer displays the matching sources inline.
node --input-type=module - "$OUTDIR" "$FE_REPO" <<'JS'
import fs from 'node:fs';
import path from 'node:path';
const [out, repo] = process.argv.slice(2);
const files = [];
function collect(dir, prefix, ingot) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const relative = path.posix.join(prefix, entry.name);
        if (entry.isDirectory()) collect(path.join(dir, entry.name), relative, ingot);
        else if (entry.name.endsWith('.fe')) files.push({
            ingot,
            basename: entry.name,
            display: `ingots/${ingot}/src/${relative}`,
            module: relative === 'lib.fe' ? ingot : `${ingot}::${relative.slice(0, -3).replaceAll('/', '::')}`,
        });
    }
}
for (const ingot of ['core', 'std']) collect(path.join(repo, 'ingots', ingot, 'src'), '', ingot);
const jsonPath = path.join(out, 'docs.json');
const docs = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
for (const item of docs.index.items) {
    const ingot = item.path.split('::')[0];
    if (!item.source || !['core', 'std'].includes(ingot)) continue;
    const candidates = files.filter(file => file.ingot === ingot
        && file.basename === item.source.display_file
        && (item.path === file.module || item.path.startsWith(`${file.module}::`)))
        .sort((a, b) => b.module.length - a.module.length);
    if (!candidates.length) throw new Error(`Cannot resolve source for ${item.path}`);
    item.source.display_file = candidates[0].display;
}
// Keep the standard library first in the viewer's navigation.
const order = { std: 0, core: 1 };
docs.index.modules.sort((a, b) => (order[a.name] ?? 2) - (order[b.name] ?? 2));
fs.writeFileSync(jsonPath, JSON.stringify(docs, null, 2) + '\n');
const indexPath = path.join(out, 'index.html');
let html = fs.readFileSync(indexPath, 'utf8').replaceAll('landing-page — Fe Documentation', 'Fe Standard Library');
html = html.replace(/\s*<script>window\.FE_SOURCE_BASE = [^<]*<\/script>/g, '');
fs.writeFileSync(indexPath, html);
JS

echo "Done."
echo "Output: $OUTDIR/{docs.json, index.html, fe-web.js, fe-highlight.css}"

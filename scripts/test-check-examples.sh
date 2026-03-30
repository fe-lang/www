#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/scripts"
cp "$SCRIPT_DIR/check-examples.sh" "$TEST_ROOT/scripts/check-examples.sh"
chmod +x "$TEST_ROOT/scripts/check-examples.sh"

cat <<'EOF' > "$TEST_ROOT/scripts/extract-fe-blocks.sh"
#!/usr/bin/env bash

set -euo pipefail

output_dir=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --output-dir)
            output_dir="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

printf '%s\n' '// snippet' > "$output_dir/sample.fe"
printf '%s:%s:%s\n' "$output_dir/sample.fe" "$output_dir/doc.md" "1" > "$output_dir/mappings.txt"
printf '%s\n' "$output_dir"
printf '%s\n' 'Extracted 1 Fe code blocks'
EOF
chmod +x "$TEST_ROOT/scripts/extract-fe-blocks.sh"

cat <<'EOF' > "$TEST_ROOT/scripts/fe"
#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "--version" ]]; then
    printf '%s\n' 'fe test-version'
    exit 0
fi

if [[ "${1:-}" == "check" ]]; then
    exit 0
fi

printf '%s\n' "unexpected args: $*" >&2
exit 1
EOF
chmod +x "$TEST_ROOT/scripts/fe"

printf '%s\n' '// boilerplate' > "$TEST_ROOT/scripts/boilerplate.fe"

output="$("$TEST_ROOT/scripts/check-examples.sh")"
expected_bin_dir="$TEST_ROOT/scripts/../bin"

printf '%s\n' "$output" | grep -F "Fe bin dir: $expected_bin_dir"
printf '%s\n' "$output" | grep -F 'Fe version: fe test-version'
printf '%s\n' "$output" | grep -F 'All Fe code examples passed type checking and tests!'

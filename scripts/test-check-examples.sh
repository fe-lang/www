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

# Exercise failures that do not contain a recognizable diagnostic string.
cat <<'MOCK' > "$TEST_ROOT/scripts/fe"
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
    --version) echo 'fe test-version' ;;
    check)
        [[ "$2" == */boilerplate.fe ]] && exit 0
        [[ "$2" == */standalone_* ]] && exit "${MOCK_STANDALONE_CHECK_STATUS:-0}"
        exit "${MOCK_CHECK_STATUS:-0}"
        ;;
    test)
        echo "${MOCK_TEST_OUTPUT:-}"
        exit "${MOCK_TEST_STATUS:-0}"
        ;;
    *) exit 2 ;;
esac
MOCK

expect_failure() {
    if output=$("$TEST_ROOT/scripts/check-examples.sh" 2>&1); then
        printf 'Expected checker failure, got success:\n%s\n' "$output" >&2
        exit 1
    fi
}

export MOCK_CHECK_STATUS=1
expect_failure
export MOCK_CHECK_STATUS=0

# Mark the extracted snippet as a test so the runtime pass is exercised.
sed 's@// snippet@#[test(should_revert)]@' "$TEST_ROOT/scripts/extract-fe-blocks.sh" > "$TEST_ROOT/extractor"
cp "$TEST_ROOT/extractor" "$TEST_ROOT/scripts/extract-fe-blocks.sh"
export MOCK_TEST_STATUS=2
export MOCK_TEST_OUTPUT='unexpected compiler error'
expect_failure
export MOCK_TEST_OUTPUT=''
expect_failure

# Standalone examples must propagate failures too.
mkdir -p "$TEST_ROOT/src/examples"
printf '%s\n' '#[test(should_revert)]' 'fn example() {}' > "$TEST_ROOT/src/examples/example.fe"
sed 's@#\[test(should_revert)\]@// snippet@' "$TEST_ROOT/scripts/extract-fe-blocks.sh" > "$TEST_ROOT/extractor"
cp "$TEST_ROOT/extractor" "$TEST_ROOT/scripts/extract-fe-blocks.sh"
expect_failure
export MOCK_TEST_STATUS=0
export MOCK_STANDALONE_CHECK_STATUS=1
expect_failure
export MOCK_STANDALONE_CHECK_STATUS=0
"$TEST_ROOT/scripts/check-examples.sh" > /dev/null
printf '%s\n' 'Exit-status regression checks passed'

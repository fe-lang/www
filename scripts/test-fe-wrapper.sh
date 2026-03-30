#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/scripts" "$TEST_ROOT/bin" "$TEST_ROOT/fake-bin"
cp "$PROJECT_ROOT/scripts/fe" "$TEST_ROOT/scripts/fe"
chmod +x "$TEST_ROOT/scripts/fe"
printf '%s\n' '// test stub' > "$TEST_ROOT/sample.fe"

cat <<'EOF' > "$TEST_ROOT/fake-bin/curl"
#!/usr/bin/env bash

set -euo pipefail

if [[ "$*" == *"api.github.com/repos/argotorg/fe/releases?per_page=1"* ]]; then
    printf '%s\n' '[{"tag_name":"v26.0.0-alpha.8"}]'
    exit 0
fi

if [[ "$*" == *"github.com/argotorg/fe/releases/download/v26.0.0-alpha.8/"* ]]; then
    output=""
    previous=""

    for arg in "$@"; do
        if [[ "$previous" == "--output" ]]; then
            output="$arg"
            break
        fi
        previous="$arg"
    done

    if [[ -z "$output" ]]; then
        echo "missing --output for download request" >&2
        exit 1
    fi

    printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$output"
    chmod +x "$output"
    exit 0
fi

echo "unexpected curl args: $*" >&2
exit 1
EOF
chmod +x "$TEST_ROOT/fake-bin/curl"

PATH="$TEST_ROOT/fake-bin:$PATH" FE_FORCE_LATEST_CHECK=1 "$TEST_ROOT/scripts/fe" check "$TEST_ROOT/sample.fe"

[[ -x "$TEST_ROOT/bin/fe" ]]
[[ -s "$TEST_ROOT/bin/.fe-last-check" ]]
[[ "$(tr -d '[:space:]' < "$TEST_ROOT/bin/.fe-version")" == "v26.0.0-alpha.8" ]]

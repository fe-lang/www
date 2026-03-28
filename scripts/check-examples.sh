#!/bin/bash
# Check Fe code examples in documentation for type errors
# Usage: check-examples.sh [--verbose] [file.md ...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
BOILERPLATE_FILE="$SCRIPT_DIR/boilerplate.fe"

if [[ -n "${FE_BIN:-}" ]]; then
    FE_BIN_PATH="$FE_BIN"
    FE_BIN_DIR="$(dirname "$FE_BIN_PATH")"
else
    FE_BIN_PATH="$PROJECT_ROOT/bin/fe"
    FE_BIN_DIR="$PROJECT_ROOT/bin"
fi

# Configuration
VERBOSE=false
FILES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: check-examples.sh [OPTIONS] [FILE...]"
            echo ""
            echo "Check Fe code examples in documentation for type errors."
            echo ""
            echo "Options:"
            echo "  -v, --verbose    Show detailed output including all files checked"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Arguments:"
            echo "  FILE...          Specific markdown files to check (default: all docs)"
            echo ""
            echo "Examples:"
            echo "  check-examples.sh                    # Check all documentation"
            echo "  check-examples.sh src/content/docs/examples/erc20.md"
            echo "  check-examples.sh --verbose"
            exit 0
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create temp directory for extracted blocks
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract Fe code blocks
if [[ "$VERBOSE" == true ]]; then
    echo "Extracting Fe code blocks..."
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    OUTPUT=$("$SCRIPT_DIR/extract-fe-blocks.sh" --output-dir "$TEMP_DIR" 2>&1)
else
    OUTPUT=$("$SCRIPT_DIR/extract-fe-blocks.sh" --output-dir "$TEMP_DIR" "${FILES[@]}" 2>&1)
fi

EXTRACT_DIR=$(echo "$OUTPUT" | head -n1)
EXTRACT_MSG=$(echo "$OUTPUT" | tail -n1)

if [[ "$VERBOSE" == true ]]; then
    echo "$EXTRACT_MSG"
fi

# Check if any blocks were extracted
MAPPINGS_FILE="$TEMP_DIR/mappings.txt"
if [[ ! -f "$MAPPINGS_FILE" ]] || [[ ! -s "$MAPPINGS_FILE" ]]; then
    echo -e "${YELLOW}No Fe code blocks found to check${NC}"
    exit 0
fi

# Count total blocks
TOTAL_BLOCKS=$(wc -l < "$MAPPINGS_FILE")

if [[ "$VERBOSE" == true ]]; then
    echo "Found $TOTAL_BLOCKS Fe code blocks to check"
    echo ""
else
    echo "Checking $TOTAL_BLOCKS Fe code blocks (use --verbose for live progress)..."
fi

# Track errors
ERRORS=()
CHECKED=0
PASSED=0
FAILED=0

ensure_fe_bootstrapped() {
    local bootstrap_output fe_version

    echo "Fe bin dir: $FE_BIN_DIR"

    if [[ "$VERBOSE" == true ]]; then
        echo "Bootstrapping Fe compiler..."
    fi

    if bootstrap_output=$("$SCRIPT_DIR/fe" check "$BOILERPLATE_FILE" 2>&1); then
        fe_version=$("$SCRIPT_DIR/fe" --version)
        echo "Fe version: $fe_version"

        if [[ "$VERBOSE" == true ]]; then
            echo -e "${GREEN}Fe compiler ready${NC}"
            echo ""
        fi
        return 0
    fi

    echo -e "${RED}Failed to bootstrap Fe compiler before example validation.${NC}" >&2
    echo "$bootstrap_output" >&2
    exit 1
}

prepare_standalone_check_file() {
    local source_file="$1"
    local output_file="$2"

    if [[ -f "$BOILERPLATE_FILE" ]]; then
        cat "$BOILERPLATE_FILE" > "$output_file"
        echo "" >> "$output_file"
        echo "// --- standalone source below ---" >> "$output_file"
        echo "" >> "$output_file"
        cat "$source_file" >> "$output_file"
    else
        cp "$source_file" "$output_file"
    fi

}

ensure_fe_bootstrapped

# Check each extracted file
while IFS=: read -r fe_file md_file block_start_line; do
    : $((CHECKED++))

    if [[ "$VERBOSE" == true ]]; then
        rel_md="${md_file#$PROJECT_ROOT/}"
        echo -n "Checking $rel_md:$block_start_line... "
    fi

    # Run fe check on the file
    FE_OUTPUT=$("$SCRIPT_DIR/fe" check "$fe_file" 2>&1) || true

    if [[ -z "$FE_OUTPUT" ]]; then
        # No output means success
        : $((PASSED++))
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${GREEN}OK${NC}"
        fi
    else
        # Has output - parse and transform error locations
        : $((FAILED++))

        if [[ "$VERBOSE" == true ]]; then
            echo -e "${RED}FAILED${NC}"
        fi

        # Get relative path for the markdown file
        rel_md="${md_file#$PROJECT_ROOT/}"

        # Transform error output to reference markdown source
        # Fe errors typically look like: /path/to/file.fe:LINE:COL: error message
        while IFS= read -r error_line; do
            if [[ "$error_line" =~ ^[^:]+\.fe:([0-9]+):([0-9]+):(.*)$ ]]; then
                fe_line="${BASH_REMATCH[1]}"
                fe_col="${BASH_REMATCH[2]}"
                error_msg="${BASH_REMATCH[3]}"

                # Calculate markdown line: block_start_line + fe_line
                # (block_start_line is the ```fe line, so code starts at +1)
                md_line=$((block_start_line + fe_line))

                ERRORS+=("$rel_md:$md_line:$fe_col:$error_msg")
            elif [[ -n "$error_line" ]]; then
                # Include other error output as-is but with file context
                ERRORS+=("$rel_md:$block_start_line: $error_line")
            fi
        done <<< "$FE_OUTPUT"
    fi
done < "$MAPPINGS_FILE"

# Check standalone .fe files in src/examples/
EXAMPLES_DIR="$PROJECT_ROOT/src/examples"
if [[ -d "$EXAMPLES_DIR" ]] && [[ ${#FILES[@]} -eq 0 ]]; then
    for fe_file in "$EXAMPLES_DIR"/*.fe; do
        [[ -f "$fe_file" ]] || continue
        : $((CHECKED++))

        rel_fe="${fe_file#$PROJECT_ROOT/}"
        if [[ "$VERBOSE" == true ]]; then
            echo -n "Checking $rel_fe... "
        fi

        temp_check_file="$TEMP_DIR/standalone_$(basename "$fe_file")"
        prepare_standalone_check_file "$fe_file" "$temp_check_file"
        FE_OUTPUT=$("$SCRIPT_DIR/fe" check "$temp_check_file" 2>&1) || true

        if [[ -z "$FE_OUTPUT" ]]; then
            : $((PASSED++))
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${GREEN}OK${NC}"
            fi
        else
            : $((FAILED++))
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${RED}FAILED${NC}"
            fi
            while IFS= read -r error_line; do
                if [[ -n "$error_line" ]]; then
                    ERRORS+=("$rel_fe: $error_line")
                fi
            done <<< "$FE_OUTPUT"
        fi
    done
fi

# Run fe test on blocks that contain #[test]
TESTED=0
TEST_PASSED=0
TEST_FAILED=0

strip_boilerplate() {
    local file="$1"
    local output="$2"
    # Extract only the snippet code after the boilerplate marker
    sed -n '/^\/\/ --- snippet code below ---$/,$ p' "$file" | tail -n +2 > "$output"
}

while IFS=: read -r fe_file md_file block_start_line; do
    # Only run fe test on blocks containing #[test]
    if ! grep -q '#\[test\]' "$fe_file" 2>/dev/null; then
        continue
    fi

    : $((TESTED++))
    rel_md="${md_file#$PROJECT_ROOT/}"

    if [[ "$VERBOSE" == true ]]; then
        echo -n "Testing $rel_md:$block_start_line... "
    fi

    # Strip boilerplate for fe test (boilerplate conflicts with built-in assert)
    raw_file="$TEMP_DIR/raw_$(basename "$fe_file")"
    strip_boilerplate "$fe_file" "$raw_file"

    FE_OUTPUT=$("$SCRIPT_DIR/fe" test "$raw_file" 2>&1) || true

    if echo "$FE_OUTPUT" | grep -q "FAILED\|failures:"; then
        : $((TEST_FAILED++))
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${RED}FAILED${NC}"
        fi
        # Extract failure info
        while IFS= read -r test_line; do
            if [[ "$test_line" =~ FAIL|revert|failure ]]; then
                ERRORS+=("$rel_md:$block_start_line: [fe test] $test_line")
            fi
        done <<< "$FE_OUTPUT"
    else
        : $((TEST_PASSED++))
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${GREEN}OK${NC}"
        fi
    fi
done < "$MAPPINGS_FILE"

# Also run fe test on standalone .fe example files
if [[ -d "$EXAMPLES_DIR" ]] && [[ ${#FILES[@]} -eq 0 ]]; then
    for fe_file in "$EXAMPLES_DIR"/*.fe; do
        [[ -f "$fe_file" ]] || continue
        # Only test files containing #[test]
        if ! grep -q '#\[test\]' "$fe_file" 2>/dev/null; then
            continue
        fi

        : $((TESTED++))
        rel_fe="${fe_file#$PROJECT_ROOT/}"

        if [[ "$VERBOSE" == true ]]; then
            echo -n "Testing $rel_fe... "
        fi

        FE_OUTPUT=$("$SCRIPT_DIR/fe" test "$fe_file" 2>&1) || true

        if echo "$FE_OUTPUT" | grep -q "FAILED\|failures:"; then
            : $((TEST_FAILED++))
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${RED}FAILED${NC}"
            fi
            while IFS= read -r test_line; do
                if [[ "$test_line" =~ FAIL|revert|failure ]]; then
                    ERRORS+=("$rel_fe: [fe test] $test_line")
                fi
            done <<< "$FE_OUTPUT"
        else
            : $((TEST_PASSED++))
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${GREEN}OK${NC}"
            fi
        fi
    done
fi

# Print summary
echo ""
echo "======================================"
echo "Fe Code Example Check Results"
echo "======================================"
echo "Total blocks checked: $CHECKED"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
if [[ $TESTED -gt 0 ]]; then
    echo ""
    echo "Test blocks executed: $TESTED"
    echo -e "Tests passed: ${GREEN}$TEST_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TEST_FAILED${NC}"
fi
echo ""

# Print errors if any
if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo -e "${RED}Errors:${NC}"
    echo ""
    for error in "${ERRORS[@]}"; do
        echo "  $error"
    done
    echo ""
    exit 1
fi

echo -e "${GREEN}All Fe code examples passed type checking and tests!${NC}"
exit 0

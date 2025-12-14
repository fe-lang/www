#!/bin/bash
# Check Fe code examples in documentation for type errors
# Usage: check-examples.sh [--verbose] [file.md ...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

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
fi

# Track errors
ERRORS=()
CHECKED=0
PASSED=0
FAILED=0

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

# Print summary
echo ""
echo "======================================"
echo "Fe Code Example Check Results"
echo "======================================"
echo "Total blocks checked: $CHECKED"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
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

echo -e "${GREEN}All Fe code examples passed type checking!${NC}"
exit 0

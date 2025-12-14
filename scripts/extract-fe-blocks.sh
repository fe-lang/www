#!/bin/bash
# Extract Fe code blocks from markdown files for type checking
# Outputs extracted blocks to a temp directory with source mapping

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Default docs directory
DOCS_DIR="$PROJECT_ROOT/src/content/docs"

# Output directory (can be overridden)
OUTPUT_DIR="${FE_EXTRACT_DIR:-$(mktemp -d)}"

# File to store source mappings
MAPPINGS_FILE="$OUTPUT_DIR/mappings.txt"

# Parse arguments
FILES=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --output-dir)
            OUTPUT_DIR="$2"
            MAPPINGS_FILE="$OUTPUT_DIR/mappings.txt"
            shift 2
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# If no files specified, find all markdown files in docs
if [[ ${#FILES[@]} -eq 0 ]]; then
    while IFS= read -r -d '' file; do
        FILES+=("$file")
    done < <(find "$DOCS_DIR" -name "*.md" -o -name "*.mdx" | tr '\n' '\0')
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Clear mappings file
> "$MAPPINGS_FILE"

# Counter for unique filenames
BLOCK_COUNT=0

# Process each markdown file
for md_file in "${FILES[@]}"; do
    # Skip if file doesn't exist
    [[ -f "$md_file" ]] || continue

    # Get relative path for cleaner output
    rel_path="${md_file#$PROJECT_ROOT/}"

    # State machine for parsing
    in_fe_block=false
    skip_block=false
    block_start_line=0
    block_content=""
    line_num=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((++line_num))

        if [[ "$in_fe_block" == false ]]; then
            # Check for start of Fe code block
            if [[ "$line" =~ ^\`\`\`fe ]]; then
                # Check if it has 'ignore' annotation
                if [[ "$line" =~ ignore ]]; then
                    skip_block=true
                    in_fe_block=true
                else
                    skip_block=false
                    in_fe_block=true
                    block_start_line=$line_num
                    block_content=""
                fi
            fi
        else
            # Check for end of code block
            if [[ "$line" =~ ^\`\`\` ]]; then
                in_fe_block=false

                # Only write if not skipped and has content
                if [[ "$skip_block" == false && -n "$block_content" ]]; then
                    ((++BLOCK_COUNT))

                    # Create a safe filename from the source path
                    safe_name=$(echo "$rel_path" | tr '/' '_' | sed 's/\.md$//' | sed 's/\.mdx$//')
                    output_file="$OUTPUT_DIR/${BLOCK_COUNT}_${safe_name}_L${block_start_line}.fe"

                    # Write the block content
                    echo "$block_content" > "$output_file"

                    # Record the mapping
                    echo "$output_file:$md_file:$block_start_line" >> "$MAPPINGS_FILE"
                fi

                skip_block=false
                block_content=""
            elif [[ "$skip_block" == false ]]; then
                # Accumulate block content
                if [[ -n "$block_content" ]]; then
                    block_content="$block_content"$'\n'"$line"
                else
                    block_content="$line"
                fi
            fi
        fi
    done < "$md_file"
done

# Output results
echo "$OUTPUT_DIR"
echo "Extracted $BLOCK_COUNT Fe code blocks" >&2

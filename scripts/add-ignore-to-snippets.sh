#!/bin/bash
# Add 'ignore' annotation to all Fe code blocks that don't already have it
# This marks them as intentional snippets that shouldn't be type-checked

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
DOCS_DIR="$PROJECT_ROOT/src/content/docs"

# Find all markdown files
find "$DOCS_DIR" -name "*.md" | while read -r file; do
    # Skip the examples directory - those should be complete examples
    if [[ "$file" == *"/examples/"* ]]; then
        continue
    fi

    # Use sed to replace ```fe (not followed by ignore) with ```fe ignore
    # The regex matches ```fe followed by either end of line or whitespace but not 'ignore'
    sed -i -E 's/^```fe(\s*)$/```fe ignore\1/g' "$file"

    echo "Processed: $file"
done

echo "Done! All Fe code blocks (except in examples/) now have 'ignore' annotation."
echo "You can now selectively remove 'ignore' from complete examples that should be checked."

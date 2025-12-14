# Change: Add Fe Syntax Highlighting

## Why
Code examples throughout the documentation display without syntax highlighting because Shiki (used by Astro/Starlight) doesn't include a Fe language definition. This makes code harder to read and the documentation less professional.

## What Changes
- Create a custom TextMate grammar for Fe language syntax
- Configure Astro/Starlight to use the custom language definition
- All `fe` code blocks will render with proper syntax highlighting

## Reference
The complete ERC20 example at `src/content/docs/examples/erc20.md` should be used as the reference for valid Fe syntax, as this code is type-checked by the Fe compiler.

## Impact
- Affected specs: documentation
- Affected code: `astro.config.mjs`, new grammar file
- All existing documentation with `fe` code blocks will automatically benefit

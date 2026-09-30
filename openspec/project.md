# Project Context

## Purpose
"The Fe Guide" is the official documentation site for Fe, a statically typed smart contract programming language for the Ethereum Virtual Machine (EVM). The guide provides comprehensive documentation covering language fundamentals, contract development patterns, and practical examples for developers building decentralized applications.

## Tech Stack
- **Astro 5.x** - Static site generator
- **Starlight** - Astro documentation theme (@astrojs/starlight)
- **TypeScript** - Configuration and type safety
- **Markdown** - Documentation content (in `src/content/docs/`)
- **Sharp** - Image processing
- **Node.js 20** - Runtime environment

## Fe Compiler

The guide targets Fe 26.4. `.fe-version` pins the release used by `scripts/fe`, the example checker and CI. The wrapper downloads and caches that release; no local source build is required. `FE_BIN` explicitly selects a local compiler and `FE_VERSION=latest` opts into latest-release resolution.

```bash
bash scripts/check-examples.sh
FE_BIN=/path/to/fe bash scripts/check-examples.sh
bash scripts/generate-docs.sh
```

The API generator uses the release compiler and its matching source checkout. Update `.fe-version` and regenerate the API when advancing the guide's compiler version.

## Project Conventions

### Code Style
- Use ES modules (`"type": "module"` in package.json)
- TypeScript strict mode via Astro's strict tsconfig
- Markdown files use frontmatter with `title` and `description` fields
- Configuration in `.mjs` files (e.g., `astro.config.mjs`)

### Architecture Patterns
- Content-driven architecture with markdown files in `src/content/docs/`
- Sidebar navigation defined in `astro.config.mjs`
- Custom CSS in `src/styles/custom.css`
- Static assets in `public/` directory

### Testing Strategy
- Build verification via `npm run build`
- Preview with `npm run preview` before deployment

### Git Workflow
- Main branch: `main`
- Automatic deployment to GitHub Pages on push to `main`
- CI/CD via GitHub Actions (`.github/workflows/deploy.yml`)

## Domain Context

**Knowledge Sources** (in order of preference):

1. **This documentation** (`src/content/docs/`): When writing new sections, consult existing documentation for patterns, syntax conventions, and examples. Key references:
   - `examples/erc20.md` - Canonical contract example with effects, messages, and recv blocks
   - `foundations/` - Core language concepts
   - `effects/` - Effect system patterns

2. **Fe compiler source**: For behavior not covered in docs or to verify accuracy:
   - Set `FE_SOURCE_PATH` environment variable to your local clone
   - Fallback: https://github.com/argotorg/fe

Fe is a statically typed smart contract language for the EVM.

### Compiler Architecture

The Fe compiler consists of these main crates:
- **parser**: Lexer (logos-based) and parser producing AST
- **hir**: Higher-level IR, semantic analysis, type system (uses Salsa for incremental computation)
- **mir**: Mid-level IR for optimizations
- **codegen**: Lowers MIR through the Sonatina backend to EVM bytecode
- **resolver**: Package/ingot dependency resolution
- **driver**: Orchestrates compilation pipeline
- **fmt**: Code formatter
- **language-server**: LSP support

**Compilation Pipeline**: Source → Parser (GreenNode/CST) → Lowering (HIR) → Semantic Analysis → MIR → Sonatina → EVM bytecode

## Important Constraints
- Site is deployed to `https://fe-lang.org/` (base path `/`)
- Must build successfully with `npm run build` before deployment
- Documentation content should be accessible and follow Starlight conventions

## External Dependencies
- **GitHub Pages**: Hosting platform
- **GitHub Actions**: CI/CD pipeline
- **Fe Language Repository**: https://github.com/argotorg/fe

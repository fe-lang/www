# The Fe Guide

The official documentation for [Fe](https://github.com/argotorg/fe), a statically typed smart contract programming language for the Ethereum Virtual Machine (EVM).

**Live site**: https://fe-lang.github.io/www/

## Overview

Fe is designed for writing safe, expressive smart contracts. Key features include:

- **Effect system**: Explicitly track state access and mutations
- **Strong typing**: Catch errors at compile time
- **Rust-inspired syntax**: Familiar patterns for systems programmers
- **EVM-native**: Compiles to efficient EVM bytecode

This documentation covers language fundamentals, contract development patterns, and practical examples.

## Project Structure

```
.
├── src/
│   ├── content/
│   │   └── docs/           # Documentation content (Markdown)
│   ├── assets/             # Images and media
│   └── styles/             # Custom CSS
├── bin/                    # Fe compiler binaries
├── scripts/
│   ├── fe                  # Platform-detecting Fe wrapper
│   └── check-examples.sh   # Validate all code snippets
├── public/                 # Static assets
├── astro.config.mjs        # Astro/Starlight configuration
└── package.json
```

## Quick Start

### Prerequisites

- Node.js 20+
- npm

### Development

```bash
# Install dependencies
npm install

# Start dev server at localhost:4321
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Validating Code Examples

All Fe code blocks in the documentation are type-checked to ensure accuracy:

```bash
# Validate all code snippets
bash scripts/check-examples.sh

# Check a specific Fe file
./scripts/fe check path/to/file.fe
```

## Commands

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Install dependencies                             |
| `npm run dev`             | Start local dev server at `localhost:4321`       |
| `npm run build`           | Build production site to `./dist/`               |
| `npm run preview`         | Preview build locally before deploying           |
| `npm run astro ...`       | Run Astro CLI commands                           |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on:

- Writing and formatting Fe code examples
- Using hide directives for boilerplate
- Validating documentation changes
- Customizing the Starlight site

## Resources

- [Fe Language Repository](https://github.com/argotorg/fe)
- [Starlight Documentation](https://starlight.astro.build/)
- [Astro Documentation](https://docs.astro.build)

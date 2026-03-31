---
title: Installation
description: Setting up the Fe compiler
---

:::caution[Not Production-Ready]
Fe 26.0 is an initial release of a new compiler. Not recommended for production use.
:::

## Quick Install (recommended)

The fastest way to install Fe is via **feup**, the Fe toolchain installer. It automatically detects your platform and downloads the latest release.

```bash
curl -fsSL https://raw.githubusercontent.com/argotorg/fe/master/feup/feup.sh | bash
```

This will:
- Install the `fe` compiler to `~/.fe/bin/`
- Install the `feup` command for future updates
- Add `~/.fe/bin` to your `PATH`

After installation, restart your shell or run:

```bash
source ~/.fe/env
```

To install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/argotorg/fe/master/feup/feup.sh | bash -s -- --version v26.0.0
```

## Homebrew

On macOS and Linux you can also install Fe via Homebrew:

```bash
brew install argotorg/tap/fe
```

## Supported Platforms

Fe provides pre-built binaries for:

| Platform | Architecture |
|----------|-------------|
| Linux    | x86_64, ARM64 |
| macOS    | x86_64, ARM64 (Apple Silicon) |
| Windows  | x86_64 |

## Verify Installation

After installing, verify that Fe is working:

```bash
fe --version
```

## Build from Source

To build the compiler from source, clone the repository and build with Cargo:

```bash
git clone https://github.com/argotorg/fe.git
cd fe
cargo install --path crates/fe
```

This requires a working [Rust toolchain](https://rustup.rs/).

## Next Steps

With Fe installed, head over to [Your First Contract](/getting-started/first-contract/) to write, deploy, and interact with a Counter contract.

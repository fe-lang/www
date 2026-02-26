---
title: Installation
description: Setting up the Fe compiler
---

:::caution[Pre-Release Software]
Fe is in active development. The current releases are alpha versions and not yet suitable for production use.
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
curl -fsSL https://raw.githubusercontent.com/argotorg/fe/master/feup/feup.sh | bash -s -- --version v26.0.0-alpha.5
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
cargo install --path crates/driver
```

This requires a working [Rust toolchain](https://rustup.rs/).

## Next Steps

With Fe installed, head over to [Key Concepts](/getting-started/key-concepts/) to learn about the language.

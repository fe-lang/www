---
title: Installation
description: Setting up the Fe compiler
---

:::caution[Not Production-Ready]
Fe is not yet recommended for production use.
:::

## Install Fe 26.4

This guide and its CI examples target **Fe 26.4.1**. Install it with **feup**, the Fe toolchain installer:

```bash
curl -fsSL https://raw.githubusercontent.com/argotorg/fe/master/feup/feup.sh | bash -s -- --version v26.4.1
```

This installs the `fe` compiler and `feup` command to `~/.fe/bin/`. Restart your shell or load the environment:

```bash
source ~/.fe/env
```

## Homebrew

On macOS and Linux you can also install Fe via Homebrew:

```bash
brew install fe-lang/tap/fe
```

The Homebrew formula can lag behind the latest release. Check the installed version as described [below](#verify-installation), and use feup if it does not report 26.4.1.

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

The version should start with `fe 26.4.1`.

## Build from Source

To build the compiler from source, clone the repository and build with Cargo:

```bash
git clone https://github.com/argotorg/fe.git
cd fe
git checkout v26.4.1
npm ci --prefix crates/tree-sitter-fe
cargo install --locked --path crates/fe
```

This requires a working [Rust toolchain](https://rustup.rs/), Node/npm to install the pinned tree-sitter generator, and a C toolchain.

## Next Steps

With Fe installed, head over to [Your First Contract](/getting-started/first-contract/) to write, deploy, and interact with a Counter contract.

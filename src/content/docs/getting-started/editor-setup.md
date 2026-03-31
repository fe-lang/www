---
title: Editor Setup
description: Setting up your editor for Fe development
---

Fe ships with a built-in language server (`fe lsp`) that provides diagnostics, go-to-definition, find references, and more. Editor plugins connect to it automatically when `fe` is on your PATH.

## VS Code

Install the [Fe extension](https://github.com/fe-lang/vscode-fe) from a `.vsix` file:

1. Download the latest `.vsix` from the [releases page](https://github.com/fe-lang/vscode-fe/releases/latest)
2. In VS Code, open the command palette (`Ctrl+Shift+P`) and run **Extensions: Install from VSIX...**, then select the downloaded file.

   Or from the command line:
   ```bash
   code --install-extension fe-*.vsix
   ```

Provides syntax highlighting, diagnostics, go-to-definition, and find references.

## Zed

The [Fe extension for Zed](https://github.com/fe-lang/zed-fe) is available as a dev extension:

1. Clone the repo: `git clone https://github.com/fe-lang/zed-fe`
2. In Zed, open **Extensions > Install Dev Extension** and select the cloned directory

## Neovim

The [nvim-fe](https://github.com/fe-lang/nvim-fe) plugin provides tree-sitter highlighting, indentation, and LSP integration.

With **lazy.nvim**:

```lua
{
    "https://github.com/fe-lang/nvim-fe",
    config = function() require("nvim_fe").setup() end,
}
```

With **packer.nvim**:

```lua
use({
    "https://github.com/fe-lang/nvim-fe",
    config = function() require("nvim_fe").setup() end,
})
```

Requires Neovim 0.9+ and a C compiler (GCC or Clang) for the tree-sitter parser.

## Emacs

The [emacs-fe](https://github.com/fe-lang/emacs-fe) package provides tree-sitter highlighting, indentation, imenu, and LSP auto-registration.

```elisp
(use-package fe
  :vc (:url "https://github.com/fe-lang/emacs-fe"
       :branch "main"))
```

To auto-start the language server with Eglot:

```elisp
(setq fe-mode-eglot-auto t)
```

Requires Emacs 29.1+ and a C compiler for the tree-sitter grammar.

## Prerequisites

All editor plugins require `fe` on your PATH. If you installed via `feup`, make sure `~/.fe/bin` is in your PATH:

```bash
source ~/.fe/env
```

You can also set the `FE_PATH` environment variable to point to the `fe` binary directly.

## Language Server Features

The Fe language server currently provides:

- **Diagnostics** -- errors and warnings as you type
- **Go-to-definition** -- jump to where a symbol is defined
- **Find references** -- find all usages of a symbol
- **Completions** -- context-aware code completion

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

**Fe Compiler Reference**: `~/Documents/hacking/ef/fe` - Always consult this codebase for accurate language behavior.

Fe is a statically typed smart contract language for the EVM. AI assistants writing documentation MUST understand these concepts accurately:

### Compiler Architecture

The Fe compiler consists of these main crates:
- **parser**: Lexer (logos-based) and parser producing AST
- **hir**: Higher-level IR, semantic analysis, type system (uses Salsa for incremental computation)
- **mir**: Mid-level IR for optimizations
- **codegen**: Generates Yul (EVM intermediate language) from HIR
- **resolver**: Package/ingot dependency resolution
- **driver**: Orchestrates compilation pipeline
- **fmt**: Code formatter
- **language-server**: LSP support

**Compilation Pipeline**: Source → Parser (GreenNode/CST) → Lowering (HIR) → Semantic Analysis → MIR → Codegen (Yul) → EVM bytecode

### Primitive Types

```
bool
i8, i16, i32, i64, i128, i256, isize    // Signed integers
u8, u16, u32, u64, u128, u256, usize    // Unsigned integers
String
```

### Composite Types

- **Structs**: `struct MyStruct { field1: i32, field2: bool }`
- **Enums**: `enum MyEnum { Variant1, Variant2(i32), Variant
- **Tuples**: `(i32, bool, u256)`
- **Arrays**: `[i32; 4]` - fixed-size arrays

### Effects System

Effects explicitly track state access via `uses` clauses. Each effect parameter has:
- Optional name binding
- Key path to the effect
- Mutability flag (`mut` for write access)

Effects appear in:
- Function signatures: `fn foo() uses (storage: state, memory: mem)`
- Contract init blocks: `init() uses (...)`
- Receive arms: `Pattern -> RetType uses (...) { body }`

### Contracts

Contracts are the top-level deployable units with:
- **fields**: Storage fields (leading contract state)
- **init**: Initialization block with optional effects
- **recv**: Multiple receive blocks for message handling

```fe
contract MyContract {
    storage_field: u256

    init() uses (...) {
        // initialization
    }

    recv MessageType {
        Pattern1 { field } -> RetType uses (...) { body }
        Pattern2 => RetType { body }
        _ => { default }
    }
}
```

### Messages and Receive Blocks

Contract entry points use pattern-matching message dispatch:
- `ContractRecv`: A receive block handling a message type
- `RecvArm`: Individual pattern-matching arms with:
  - Pattern on message fields
  - Optional return type
  - Optional uses clause for effects
  - Block body

### Top-Level Items

1. **Modules** (`mod`) - Nested module definitions
2. **Functions** (`fn`) - With optional `uses` clauses
3. **Structs** (`struct`) - With generic parameters and where clauses
4. **Contracts** (`contract`) - EVM contract definitions
5. **Enums** (`enum`) - With generic parameters and variants
6. **Type Aliases** (`type`) - Generic type aliases
7. **Traits** (`trait`) - With associated types, constants, super-traits
8. **Impl blocks** (`impl`) - Type implementations
9. **Trait implementations** (`impl Trait for Type`)
10. **Constants** (`const`) - Module-level constants
11. **Use statements** (`use`) - Imports

### Trait System

- Associated types: `type Output` in traits
- Associated constants: `const SELECTOR: u32` in traits
- Super-traits: `trait Child: Parent {}`
- Generic bounds: `T: Trait + OtherTrait`
- Where clauses: `where T: Trait`

### Expression Types

- Block: `{ stmt1; stmt2; expr }`
- Binary/Unary operations
- Function calls with generics: `foo::<T>(args)`
- Method calls: `obj.method(args)`
- Record initialization: `MyStruct { field: value }`
- Field access: `obj.field`
- Indexing: `arr[i]`
- Tuples: `(a, b, c)`
- Arrays: `[1, 2, 3]` and `[expr; count]`
- Literals: integers, booleans, strings
- If-else: `if cond { } else { }`
- Match: `match expr { pat => body }`
- Assignment: `x = value`, `x += value`

### Pattern Matching

- Struct patterns: `MyStruct { x: 1, y: _ }`
- Tuple patterns: `(a, b, _)`
- Enum variants with data
- Wildcards: `_`
- Bindings: `x`, `mut x`

### Storage System

- Storage accessed through effects (`uses` clauses)
- `StorageMap<K, V>`: Key-value persistent storage
- `StorageKey` trait: Defines valid storage keys
- Low-level: `sload(slot)`, `sstore(slot, value)`

### Built-in Intrinsics (EVM Operations)

**Memory**:
- `mload(addr)`, `mstore(addr, val)`, `mstore8(addr, val)`

**Calldata**:
- `calldataload(offset)`, `calldatacopy(dest, offset, len)`

**Storage**:
- `sload(slot)`, `sstore(slot, value)`

**Code**:
- `codecopy(dest, offset, len)`
- `code_region_offset<F>()`, `code_region_len<F>()`

**Return/Revert**:
- `return_data(offset, size)`, `revert(offset, size)`

**Environment**:
- `caller()`, `addr_of<T>(ptr)`

**Hashing**:
- `keccak(offset, size)`

**Creation**:
- `create2(value, offset, len, salt)`

### Core Library Types

- `Option<T>`: With `map`, `and_then`, `unwrap` methods (Monad implementation)
- `Result<T, E>`: Error handling
- `StorageMap<K, V>`: Storage-backed mapping

**Operator Traits**:
- Arithmetic: `Add`, `Sub`, `Mul`, `Div`, `Rem`, `Pow`
- Bitwise: `BitAnd`, `BitOr`, `BitXor`, `Shl`, `Shr`, `BitNot`
- Unary: `Neg`, `Not`
- Comparison: `Eq`, `Ord`

**Functional Traits**: `Default`, `Fn`, `Functor`, `Applicative`, `Monad`

### Keywords

`as`, `true`, `false`, `break`, `continue`, `contract`, `msg`, `fn`, `mod`, `const`, `if`, `else`, `match`, `for`, `in`, `where`, `while`, `pub`, `return`, `self`, `Self`, `struct`, `enum`, `trait`, `impl`, `use`, `extern`, `uses`

### Operators

- Arithmetic: `+`, `-`, `*`, `**` (power), `/`, `%`
- Bitwise: `&`, `|`, `^`, `~`, `<<`, `>>`
- Logical: `&&`, `||`, `!`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Other: `->`, `=>`, `::`

### Ingots (Package Management)

- Fe's term for packages/crates
- Git-based dependency resolution
- Local and remote dependencies supported
- Module tree built from ingot structure

## Important Constraints
- Site is deployed to `https://fe-lang.github.io/www/` (note the `/www/` base path)
- Must build successfully with `npm run build` before deployment
- Documentation content should be accessible and follow Starlight conventions

## External Dependencies
- **GitHub Pages**: Hosting platform
- **GitHub Actions**: CI/CD pipeline
- **Fe Language Repository**: https://github.com/fe-lang/fe

# The Fe Guide - Content Brief

## Overview

This document outlines "The Fe Guide" - comprehensive documentation for the Fe smart contract language, targeting Solidity developers and blockchain engineers looking for a safer, more expressive alternative.

## Target Audience

**Primary:** Solidity developers and blockchain engineers who:
- Have written smart contracts before
- Are frustrated with Solidity's footguns (reentrancy, hidden state, inheritance hell)
- Want something more principled without leaving the EVM
- Appreciate Rust's ideas but need EVM-native tooling

**Secondary:** Rust developers entering blockchain who want familiar syntax and safety guarantees.

## Core Messaging

### The Hook

Fe is what Solidity should have been: explicit, safe, and expressive. No hidden state access. No inheritance nightmares. No wondering what `msg.sender` is buried five calls deep.

### Key Differentiators

1. **Effects System (`uses`)** - Every function declares exactly what state it reads or writes. No surprises. No hidden dependencies. Auditors love it.

2. **Message-Based Interfaces (`msg` + `recv`)** - Define your contract's public interface separately from implementation. Clean ABI definitions. Multiple interfaces per contract.

3. **Composition Over Inheritance** - No more diamond problems. No more hunting through 12 inherited contracts. Build with structs and impl blocks.

4. **Named Parameters** - `transfer(to: alice, amount: 100)` not `transfer(alice, 100)`. Self-documenting code.

5. **Rust-Inspired Syntax** - Pattern matching, proper enums, type inference. Modern language design.

---

## Guide Structure

### Part 1: Getting Started

**Goal:** Get developers excited and productive in 10 minutes.

**Content:**
- What is Fe and why it exists
- Installation (one command)
- First contract with side-by-side Solidity comparison
- "Hello, Blockchain" deployment

**Tone:** Welcoming, fast-paced, show don't tell.

---

### Part 2: Language Basics

**Goal:** Cover familiar ground quickly, highlight improvements.

**Content:**
- Types: `u256`, `Address`, `bool`, `String<N>` (familiar + new)
- Variables: `let` and `mut` (no `storage`/`memory` keywords to memorize)
- Functions: Named parameters, clean syntax
- Control flow: `if`, `match` (pattern matching!), loops

**Tone:** "You know this, but here's how Fe does it better."

---

### Part 3: Structs & Maps

**Goal:** Show how Fe handles data without inheritance.

**Content:**
- Structs with methods (impl blocks)
- `Map<K, V>` with compound keys: `Map<(Address, Address), u256>`
- Composition patterns: helper structs like `AccessControl`
- Why no inheritance is a feature, not a limitation

**Tone:** Practical, pattern-focused.

---

### Part 4: Effects - Explicit State Dependencies

**Goal:** This is Fe's killer feature. Explain it thoroughly.

**The Problem (Solidity):**
```solidity
function transfer(address to, uint amount) external {
    // What state does this touch? You have to read every line.
    // What about internal calls? Hope you checked those too.
    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

**The Solution (Fe):**
```fe
fn transfer(from: Address, to: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    // The signature tells you EXACTLY what this function can touch.
    // store: reads/writes token balances
    // log: emits events
    // Nothing else. Guaranteed.
}
```

**Content:**
- What effects are and why they matter
- `uses` clause syntax
- `mut` for write access, omit for read-only
- Built-in effects: `Ctx` (caller, block info), `Log` (events)
- Effect propagation through call chains
- Benefits: testability, auditability, no surprise state changes

**Tone:** "This changes everything. Here's why."

---

### Part 5: Messages - Defining Your Contract Interface

**Goal:** Explain Fe's clean approach to public interfaces.

**Solidity's Problem:**
```solidity
// Visibility scattered everywhere
// ABI is implicit
// What's the actual interface? Read every function.
function transfer(address to, uint256 amount) external returns (bool) { ... }
function balanceOf(address account) public view returns (uint256) { ... }
```

**Fe's Solution:**
```fe
// Interface defined in one place, explicit selectors
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: Address, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: Address } -> u256,
}
```

**Content:**
- `msg` declarations define your ABI
- Explicit selectors for compatibility
- Message groups as interfaces
- Clean separation of interface and implementation

**Tone:** "Finally, a sane way to define contract interfaces."

---

### Part 6: Contracts & Receive Blocks

**Goal:** Show how contracts are structured in Fe.

**Content:**
- Contract declaration with effects
- Storage as struct fields
- `init` block (constructor)
- `recv` blocks - handling messages with per-handler effects

**Example:**
```fe
pub contract CoolCoin uses (mut ctx: Ctx, mut log: Log) {
    mut store: TokenStore,
    mut auth: AccessControl,

    init(initial_supply: u256, owner: Address)
      uses (mut store, mut auth, mut ctx, mut log)
    {
        auth.grant(role: MINTER, to: owner)
        if initial_supply > 0 {
            mint(to: owner, amount: initial_supply)
        }
    }

    recv Erc20 {
        Transfer { to, amount } -> bool uses (ctx, mut store, mut log) {
            transfer(from: ctx.caller(), to, amount)
            true
        }

        BalanceOf { account } -> u256 uses store {
            store.balances[account]
        }
    }
}
```

**Tone:** Show the elegance. Let the code speak.

---

### Part 7: Events

**Goal:** Quick chapter on event emission.

**Content:**
- Events as structs with `#[indexed]` fields
- Explicit emission via `Log` effect
- `log.emit(TransferEvent { from, to, value })`

**Tone:** Straightforward, practical.

---

### Part 8: Error Handling

**Goal:** Simple and clear.

**Content:**
- `assert(condition, "message")` - that's it
- No `require` vs `revert` confusion
- Clear error messages

**Tone:** "Simpler than Solidity. On purpose."

---

### Part 9: Access Control

**Goal:** Show a real-world pattern.

**Content:**
- Role-based access as a reusable struct
- `auth.grant()`, `auth.revoke()`, `auth.require()`
- Composition in action

**Example:**
```fe
const MINTER: u256 = 1
const BURNER: u256 = 2

// In contract:
auth.grant(role: MINTER, to: owner)

// In handler:
recv Erc20Extended {
    Mint { to, amount } -> bool uses (ctx, mut store, mut log, auth) {
        auth.require(role: MINTER)
        mint(to, amount)
        true
    }
}
```

**Tone:** Practical, reusable patterns.

---

### Part 10: Complete Example - ERC20 Token

**Goal:** Full walkthrough of a production-quality token.

**Content:**
- Complete CoolCoin implementation
- Token storage structure
- Standard ERC20 interface
- Extended features (mint, burn)
- Access control integration

**Tone:** "Here's how it all fits together."

---

### Part 11: Patterns for Solidity Developers

**Goal:** Direct answers to "where's my X?"

| Solidity | Fe |
|----------|-----|
| `msg.sender` | `ctx.caller()` |
| `mapping(address => uint)` | `Map<Address, u256>` |
| `constructor()` | `init(...) { }` |
| `require(x, "msg")` | `assert(x, "msg")` |
| `emit Transfer(...)` | `log.emit(TransferEvent { ... })` |
| `modifier onlyOwner` | `auth.require(role: OWNER)` |
| `contract A is B, C` | Composition with structs |
| `external`/`public`/`internal` | `msg` for public, everything else internal |
| `view`/`pure` | Inferred from `uses` clause |

**Tone:** Quick reference, no fluff.

---

### Part 12: Testing

**Goal:** Show how effects make testing easier.

**Content:**
- Unit testing internal functions
- Mocking effects (provide test `Ctx`, `Log`)
- Integration testing
- `fe test` runner

**Tone:** Practical, test-driven.

---

### Appendices

- **A: Type Comparison Table** - Solidity → Fe
- **B: Common Selectors** - ERC20, ERC721
- **C: Keyword Reference**
- **D: Intrinsics** - Low-level EVM access
- **E: Migration Checklist** - Porting Solidity to Fe

---

## Content Guidelines

### Voice & Tone

- **Confident but not arrogant** - Fe is better in specific ways, explain why
- **Practical over theoretical** - Show code, not philosophy
- **Respectful of Solidity** - Developers aren't dumb for using it, Fe is just the next step
- **Concise** - Blockchain developers value their time

### Code Examples

- Always show Fe code, often with Solidity comparison
- Use realistic examples (ERC20, access control) not toy examples
- Syntax highlight appropriately
- Keep examples short but complete

### Visuals (Suggestions)

- Effect flow diagrams (what can touch what)
- Contract structure diagrams
- Side-by-side Solidity/Fe comparisons
- Message → Handler flow

### SEO Keywords

- Fe language
- Solidity alternative
- Safe smart contracts
- EVM smart contract language
- Rust-like smart contracts
- Smart contract effects
- Ethereum development

---

## Calls to Action

Each section should end with:
1. Link to next section
2. Link to relevant example code
3. "Try it yourself" prompt where applicable

Final CTA: "Ready to write safer contracts? [Install Fe →]"

---

## Success Metrics

The guide succeeds if a Solidity developer can:
1. Understand Fe's value proposition in 5 minutes
2. Write a basic contract in 30 minutes
3. Port a simple Solidity contract in an afternoon
4. Explain effects to a colleague

---

## Notes for Content Creator

- The `tmp.md` file in this repo contains a full ERC20 example showing the target syntax
- Effects (`uses`) and messages (`msg`/`recv`) are the two features to emphasize most
- Don't shy away from showing that Fe requires more explicit code - frame it as "explicit is better than implicit"
- The Rust comparison is secondary; Solidity comparison is primary

---
title: Complete ERC20
description: Full walkthrough of CoolCoin
---

This chapter presents a complete ERC20 token implementation called CoolCoin. This example demonstrates real Fe patterns including contract-level effects, storage structs, access control, events, and message handling.

## Full Source Code

```fe
// roles
const MINTER: u256 = 1
const BURNER: u256 = 2

pub contract CoolCoin uses (mut ctx: Ctx, mut log: Log) {
    // Storage fields. These act as effects within the contract.
    mut store: TokenStore,
    mut auth: AccessControl,

    // Initialize the token with name, symbol, decimals, and initial supply
    init(initial_supply: u256, owner: Address)
      uses (mut store, mut auth, mut ctx, mut log)
    {
        auth.grant(role: MINTER, to: owner)
        auth.grant(role: BURNER, to: owner)

        if initial_supply > 0 {
            mint(to: owner, amount: initial_supply)
        }
    }

    recv Erc20 {
        Transfer { to, amount } -> bool uses (ctx, mut store, mut log) {
            transfer(from: ctx.caller(), to, amount)
            true
        }

        Approve { spender, amount } -> bool uses (ctx, mut store, mut log) {
            approve(owner: ctx.caller(), spender, amount)
            true
        }

        TransferFrom { from, to, amount } -> bool uses (ctx, mut store, mut log) {
            spend_allowance(owner: from, spender: ctx.caller(), amount)
            transfer(from, to, amount)
            true
        }

        BalanceOf { account } -> u256 uses store {
            store.balances[account]
        }

        Allowance { owner, spender } -> u256 uses (store) {
            store.allowances[(owner, spender)]
        }

        TotalSupply {} -> u256 uses store {
            store.total_supply
        }

        Name {} -> String<32> { "CoolCoin" }
        Symbol {} -> String<8> { "COOL" }
        Decimals {} -> u8 { 18 }
    }

    // Extended functionality (minting and burning)
    recv Erc20Extended {
        Mint { to, amount } -> bool uses (ctx, mut store, mut log, auth) {
            auth.require(role: MINTER)
            mint(to, amount)
            true
        }

        // Burns tokens from caller's balance
        Burn { amount } -> bool uses (ctx, mut store, mut log) {
            burn(from: ctx.caller(), amount)
            true
        }

        // Burns tokens from an account using allowance (requires BURNER or allowance)
        BurnFrom { from, amount } -> bool uses (ctx, mut store, mut log) {
            spend_allowance(owner: from, spender: ctx.caller(), amount)
            burn(from, amount)
            true
        }

        IncreaseAllowance { spender, added_value } -> bool
        uses (ctx, mut store, mut log)
        {
            let owner = ctx.caller()
            let current = store.allowances[(owner, spender)]
            approve(owner, spender, amount: current + added_value)
            true
        }

        DecreaseAllowance { spender, subtracted_value } -> bool
        uses (ctx, mut store, mut log) {
            let owner = ctx.caller()
            let current = store.allowances[(owner, spender)]
            assert(current >= subtracted_value, "decreased allowance below zero")
            approve(owner, spender, amount: current - subtracted_value)
            true
        }
    }
}

fn transfer(from: Address, to: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    assert(from != Address::zero(), "transfer from zero address")
    assert(to != Address::zero(), "transfer to zero address")

    let from_balance = store.balances[from]
    assert(from_balance >= amount, "transfer amount exceeds balance")

    store.balances[from] = from_balance - amount
    store.balances[to] += amount

    log.emit(TransferEvent { from, to, value: amount })
}

fn mint(to: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    assert(to != Address::zero(), "mint to zero address")

    store.total_supply += amount
    store.balances[to] += amount

    log.emit(TransferEvent { from: Address::zero(), to, value: amount })
}

fn burn(from: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    assert(from != Address::zero(), "burn from zero address")

    let from_balance = store.balances[from]
    assert(from_balance >= amount, "burn amount exceeds balance")

    store.balances[from] = from_balance - amount
    store.total_supply -= amount

    log.emit(TransferEvent { from, to: Address::zero(), value: amount })
}

fn approve(owner: Address, spender: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    assert(owner != Address::zero(), "approve from zero address")
    assert(spender != Address::zero(), "approve to zero address")

    store.allowances[(owner, spender)] = amount

    log.emit(ApprovalEvent { owner, spender, value: amount })
}

// Internal function to spend allowance
fn spend_allowance(owner: Address, spender: Address, amount: u256)
    uses (mut store: TokenStore)
{
    let current = store.allowances[(owner, spender)]
    // if current != u256::MAX { // TODO: define ::MAX constants
        assert(current >= amount, "insufficient allowance")
        store.allowances[(owner, spender)] = current - amount
    // }
}

struct TokenStore {
    total_supply: u256,
    balances: Map<Address, u256>,
    allowances: Map<(Address, Address), u256>,
}

pub struct AccessControl {
    roles: Map<(u256, Address), bool>,
}

impl AccessControl {
    pub fn new() -> Self {
        AccessControl {
            roles: Map::new(),
        }
    }

    pub fn has_role(self, role: u256, account: Address) -> bool {
        self.roles[(role, account)]
    }

    pub fn require(self, role: u256) uses (ctx: Ctx) {
        assert(self.roles[(role, ctx.caller())], "access denied: missing role")
    }

    pub fn grant(mut self, role: u256, to: Address) {
        self.roles[(role, to)] = true
    }

    pub fn revoke(mut self, role: u256, from: Address) {
        self.roles[(role, from)] = false
    }
}

// ERC20 standard message types
msg Erc20 {
    #[selector = 0x06fdde03]
    Name -> String<32>,

    #[selector = 0x95d89b41]
    Symbol -> String<8>,

    #[selector = 0x313ce567]
    Decimals -> u8,

    #[selector = 0x18160ddd]
    TotalSupply -> u256,

    #[selector = 0x70a08231]
    BalanceOf { account: Address } -> u256,

    #[selector = 0xdd62ed3e]
    Allowance { owner: Address, spender: Address } -> u256,

    #[selector = 0xa9059cbb]
    Transfer { to: Address, amount: u256 } -> bool,

    #[selector = 0x095ea7b3]
    Approve { spender: Address, amount: u256 } -> bool,

    #[selector = 0x23b872dd]
    TransferFrom { from: Address, to: Address, amount: u256 } -> bool,
}

// Extended ERC20 message types (minting, burning, allowance helpers)
msg Erc20Extended {
    #[selector = 0x40c10f19]
    Mint { to: Address, amount: u256 } -> bool,

    #[selector = 0x42966c68]
    Burn { amount: u256 } -> bool,

    #[selector = 0x79cc6790]
    BurnFrom { from: Address, amount: u256 } -> bool,

    #[selector = 0x39509351]
    IncreaseAllowance { spender: Address, added_value: u256 } -> bool,

    #[selector = 0xa457c2d7]
    DecreaseAllowance { spender: Address, subtracted_value: u256 } -> bool,
}

// ERC20 events
struct TransferEvent {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

struct ApprovalEvent {
    #[indexed]
    owner: Address,
    #[indexed]
    spender: Address,
    value: u256,
}

// stubs for missing std lib stuff
extern {
    fn assert(_: bool, _: String<64>)
}

pub struct Address { inner: u256 }
impl Address {
    pub fn zero() -> Self {
        Address { inner: 0 }
    }
}
impl core::ops::Eq for Address {
    fn eq(self, _ other: Address) -> bool {
        self.inner == other.inner
    }
}

pub struct Map<K, V> {}
impl<K, V> Map<K, V> {
    pub fn new() -> Self {
        Map {}
    }
}
impl<K, V> core::ops::Index<K> for Map<K, V> {
    type Output = V
    fn index(self, _ key: K) -> V {
        todo()
    }
}

pub struct Ctx {}
impl Ctx {
    pub fn caller(self) -> Address {
        todo()
    }
}

pub struct Log {}
impl Log {
    pub fn emit<T>(self, _ event: T) {
        todo()
    }
}
```

## Walkthrough

### Contract Declaration and Effects

The contract declares effects at the contract level:

```fe ignore
pub contract CoolCoin uses (mut ctx: Ctx, mut log: Log) {
    mut store: TokenStore,
    mut auth: AccessControl,
```

Key points:
- `uses (mut ctx: Ctx, mut log: Log)` declares contract-wide effects
- `Ctx` provides execution context (caller address, block info)
- `Log` provides event emission capability
- `store` and `auth` are storage fields that act as effects within the contract

### Storage Structs

The contract uses two storage structs:

```fe ignore
struct TokenStore {
    total_supply: u256,
    balances: Map<Address, u256>,
    allowances: Map<(Address, Address), u256>,
}

pub struct AccessControl {
    roles: Map<(u256, Address), bool>,
}
```

`TokenStore` holds all ERC20 state:
- `total_supply`: Total tokens in circulation
- `balances`: Maps addresses to their token balances
- `allowances`: Maps (owner, spender) pairs to approved amounts

`AccessControl` manages role-based permissions using a map from (role, address) to boolean.

### Message Definitions

Messages define the external interface with ABI-compatible selectors:

```fe ignore
msg Erc20 {
    #[selector = 0x06fdde03]
    Name -> String<32>,

    #[selector = 0xa9059cbb]
    Transfer { to: Address, amount: u256 } -> bool,
    // ...
}
```

The `Erc20` message group covers standard ERC20 functions. The `Erc20Extended` group adds minting, burning, and allowance helpers.

Each selector matches the standard Solidity function selector, ensuring ABI compatibility.

### The init Block

```fe ignore
init(initial_supply: u256, owner: Address)
  uses (mut store, mut auth, mut ctx, mut log)
{
    auth.grant(role: MINTER, to: owner)
    auth.grant(role: BURNER, to: owner)

    if initial_supply > 0 {
        mint(to: owner, amount: initial_supply)
    }
}
```

The constructor:
1. Grants MINTER and BURNER roles to the owner
2. Mints initial supply to the owner if non-zero
3. Declares which effects it uses from the contract

### Receive Blocks and Handlers

Each handler declares its specific effect requirements:

```fe ignore
recv Erc20 {
    Transfer { to, amount } -> bool uses (ctx, mut store, mut log) {
        transfer(from: ctx.caller(), to, amount)
        true
    }

    BalanceOf { account } -> u256 uses store {
        store.balances[account]
    }
}
```

Notice:
- `Transfer` needs `ctx` (for caller), `mut store` (to modify balances), and `mut log` (to emit event)
- `BalanceOf` only needs `store` (read-only) - no `mut` required
- Handlers delegate to helper functions for the actual logic

### Helper Functions

Core logic is extracted into standalone functions:

```fe ignore
fn transfer(from: Address, to: Address, amount: u256)
    uses (mut store: TokenStore, mut log: Log)
{
    assert(from != Address::zero(), "transfer from zero address")
    assert(to != Address::zero(), "transfer to zero address")

    let from_balance = store.balances[from]
    assert(from_balance >= amount, "transfer amount exceeds balance")

    store.balances[from] = from_balance - amount
    store.balances[to] += amount

    log.emit(TransferEvent { from, to, value: amount })
}
```

This pattern:
- Validates inputs with assertions
- Updates state
- Emits event after successful state change
- Declares explicit effect requirements in the signature

The `mint` and `burn` functions follow the same pattern, using `Address::zero()` as the source/destination to indicate minting/burning.

### Events

Events are structs with `#[indexed]` fields for filtering:

```fe ignore
struct TransferEvent {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

struct ApprovalEvent {
    #[indexed]
    owner: Address,
    #[indexed]
    spender: Address,
    value: u256,
}
```

Events are emitted via the Log effect:

```fe ignore
log.emit(TransferEvent { from, to, value: amount })
```

### Access Control

Role-based access control is implemented as a struct with methods:

```fe ignore
const MINTER: u256 = 1
const BURNER: u256 = 2

impl AccessControl {
    pub fn require(self, role: u256) uses (ctx: Ctx) {
        assert(self.roles[(role, ctx.caller())], "access denied: missing role")
    }

    pub fn grant(mut self, role: u256, to: Address) {
        self.roles[(role, to)] = true
    }
}
```

Usage in handlers:

```fe ignore
Mint { to, amount } -> bool uses (ctx, mut store, mut log, auth) {
    auth.require(role: MINTER)
    mint(to, amount)
    true
}
```

The `require` method checks if the caller has the specified role, reverting if not.

## Key Patterns

| Pattern | Example |
|---------|---------|
| Contract-level effects | `contract CoolCoin uses (mut ctx: Ctx, mut log: Log)` |
| Storage as fields | `mut store: TokenStore` |
| Handler-specific effects | `uses (ctx, mut store, mut log)` |
| Effect in helpers | `fn transfer(...) uses (mut store: TokenStore, mut log: Log)` |
| Event emission | `log.emit(TransferEvent { ... })` |
| Role-based access | `auth.require(role: MINTER)` |
| Zero address checks | `assert(to != Address::zero(), "...")` |

## Summary

CoolCoin demonstrates how to build a production-quality ERC20 token in Fe:

1. **Explicit effects** make capabilities visible in signatures
2. **Storage structs** organize related state
3. **Message groups** define ABI-compatible interfaces
4. **Helper functions** encapsulate reusable logic
5. **Access control** protects privileged operations
6. **Events** record state changes for off-chain indexing

This pattern scales to more complex contracts while maintaining clarity about what each component can do.

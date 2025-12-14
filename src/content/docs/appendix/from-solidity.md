---
title: Fe for Solidity Developers
description: Migration guide from Solidity
---

This guide helps Solidity developers understand Fe by highlighting key differences and showing equivalent patterns.

## Key Conceptual Differences

### Explicit Effects vs Implicit State

**Solidity**: Functions can access any state variable implicitly.

```solidity
contract Token {
    mapping(address => uint256) balances;

    function transfer(address to, uint256 amount) public {
        balances[msg.sender] -= amount;  // Implicit access
        balances[to] += amount;
    }
}
```

**Fe**: Functions must declare what state they access via effects.

```fe ignore
fn transfer(from: Address, to: Address, amount: u256)
    uses mut store: TokenStore  // Explicit declaration
{
    store.balances[from] -= amount
    store.balances[to] += amount
}
```

### Contracts vs Messages

**Solidity**: Functions are defined directly in contracts.

```solidity
contract Token {
    function transfer(address to, uint256 amount) public returns (bool) {
        // ...
    }
}
```

**Fe**: External interface is defined separately via messages.

```fe ignore
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: Address, amount: u256 } -> bool,
}

contract Token {
    recv TokenMsg {
        Transfer { to, amount } -> bool {
            // ...
        }
    }
}
```

### Storage Access

**Solidity**: Direct access to state variables.

```solidity
balances[msg.sender] = 100;
```

**Fe**: Access through effect-bound storage.

```fe ignore
// In recv block
with (TokenStorage = store) {
    TokenStorage.balances[caller()] = 100
}
```

## Syntax Comparison

### Variable Declaration

| Solidity | Fe |
|----------|-----|
| `uint256 x = 10;` | `let x: u256 = 10` |
| `uint256 x;` | `let x: u256 = 0` |
| `address owner;` | `let owner: Address` |
| `bool active = true;` | `let active: bool = true` |

### Types

| Solidity | Fe |
|----------|-----|
| `uint256` | `u256` |
| `int256` | `i256` |
| `uint8` | `u8` |
| `address` | `Address` |
| `bool` | `bool` |
| `string` | `String<N>` |
| `bytes32` | `u256` |
| `mapping(K => V)` | `Map<K, V>` |

### Functions

**Solidity**:
```solidity
function add(uint256 a, uint256 b) public pure returns (uint256) {
    return a + b;
}
```

**Fe**:
```fe ignore
fn add(a: u256, b: u256) -> u256 {
    a + b
}
```

### Visibility

| Solidity | Fe |
|----------|-----|
| `public` | `pub` |
| `private` | (default) |
| `internal` | (default within module) |
| `external` | via `msg` and `recv` |

### Control Flow

**Solidity**:
```solidity
if (x > 0) {
    return true;
} else {
    return false;
}

for (uint i = 0; i < 10; i++) {
    // ...
}
```

**Fe**:
```fe ignore
if x > 0 {
    return true
} else {
    return false
}

for i in 0..10 {
    // ...
}
```

### Events

**Solidity**:
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);

function transfer(...) {
    emit Transfer(from, to, amount);
}
```

**Fe**:
```fe ignore
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

fn transfer(...) uses mut log: Log {
    log.emit(Transfer { from, to, value: amount })
}
```

### Error Handling

**Solidity**:
```solidity
require(balance >= amount, "Insufficient balance");
revert("Error message");
```

**Fe**:
```fe ignore
assert(balance >= amount, "Insufficient balance")
revert
```

### Constructors

**Solidity**:
```solidity
constructor(uint256 initialSupply) {
    totalSupply = initialSupply;
}
```

**Fe**:
```fe ignore
contract Token {
    init(initial_supply: u256) uses mut store {
        store.total_supply = initial_supply
    }
}
```

## Pattern Equivalents

### ERC20 Transfer

**Solidity**:
```solidity
function transfer(address to, uint256 amount) public returns (bool) {
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    balances[to] += amount;
    emit Transfer(msg.sender, to, amount);
    return true;
}
```

**Fe**:
```fe ignore
Transfer { to, amount } -> bool uses (ctx, mut store, mut log) {
    let from = ctx.caller()
    assert(store.balances[from] >= amount, "Insufficient balance")
    store.balances[from] -= amount
    store.balances[to] += amount
    log.emit(TransferEvent { from, to, value: amount })
    true
}
```

### Access Control

**Solidity**:
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}

function mint(address to, uint256 amount) public onlyOwner {
    // ...
}
```

**Fe**:
```fe ignore
fn require_owner(owner: Address) uses ctx: Ctx {
    assert(ctx.caller() == owner, "Not owner")
}

Mint { to, amount } -> bool uses (ctx, mut store, auth) {
    auth.require(role: MINTER)  // Or: require_owner(store.owner)
    // ...
}
```

### Mappings

**Solidity**:
```solidity
mapping(address => mapping(address => uint256)) allowances;

allowances[owner][spender] = amount;
uint256 allowed = allowances[owner][spender];
```

**Fe**:
```fe ignore
struct Storage {
    allowances: Map<(Address, Address), u256>,
}

store.allowances[(owner, spender)] = amount
let allowed = store.allowances[(owner, spender)]
```

## What's Different in Fe

### No Inheritance

Fe doesn't have contract inheritance. Use composition instead:

```fe ignore
// Instead of: contract Token is Ownable, Pausable
contract Token {
    auth: AccessControl,    // Composition
    pause_state: Pausable,  // Composition
}
```

### No Modifiers

Fe doesn't have function modifiers. Use helper functions:

```fe ignore
fn require_not_paused(paused: bool) {
    assert(!paused, "Contract is paused")
}

// In handler:
require_not_paused(store.paused)
```

### Explicit Selectors

Fe requires explicit ABI selectors:

```fe ignore
msg TokenMsg {
    #[selector = 0xa9059cbb]  // Must specify
    Transfer { to: Address, amount: u256 } -> bool,
}
```

### No Overloading

Fe doesn't support function overloading. Use different names:

```fe ignore
// Instead of transfer(address) and transfer(address, uint256)
fn transfer_to(to: Address) { ... }
fn transfer_amount(to: Address, amount: u256) { ... }
```

### Type Inference

Fe infers types where possible:

```fe ignore
let x = 10        // u256 inferred
let y: u8 = 10    // Explicit when needed
```

## Migration Tips

1. **Start with messages** - Define your external interface first with explicit selectors

2. **Group storage** - Create storage structs instead of individual state variables

3. **Add effect annotations** - Every function touching state needs `uses` clauses

4. **Replace modifiers** - Convert to helper functions with assertions

5. **Use composition** - Replace inheritance with struct fields

6. **Test selectors** - Verify your selectors match the Solidity ABI

## Quick Reference

| Solidity | Fe |
|----------|-----|
| `msg.sender` | `ctx.caller()` |
| `block.timestamp` | `ctx.block_timestamp()` |
| `block.number` | `ctx.block_number()` |
| `require(...)` | `assert(...)` |
| `emit Event(...)` | `log.emit(Event { ... })` |
| `mapping(K => V)` | `Map<K, V>` |
| `constructor` | `init` |
| `function` | `fn` |
| `public` | `pub` |
| `returns` | `->` |

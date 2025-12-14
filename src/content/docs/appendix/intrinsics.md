---
title: Intrinsics Reference
description: Fe intrinsic functions
---

Intrinsics are built-in functions that provide direct access to EVM operations and low-level functionality. This appendix documents available intrinsics in Fe.

## Context Intrinsics

These intrinsics provide information about the execution context:

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `caller()` | `Address` | Address that called this contract |
| `block_number()` | `u256` | Current block number |
| `block_timestamp()` | `u256` | Current block timestamp (seconds since epoch) |
| `block_coinbase()` | `Address` | Current block miner/validator address |
| `block_difficulty()` | `u256` | Current block difficulty |
| `block_gaslimit()` | `u256` | Current block gas limit |
| `chain_id()` | `u256` | Current chain ID |
| `origin()` | `Address` | Original transaction sender |
| `gas_price()` | `u256` | Gas price of the transaction |
| `gas_remaining()` | `u256` | Remaining gas for execution |

### Usage

```fe ignore
fn only_owner(owner: Address) uses ctx: Ctx {
    assert(ctx.caller() == owner, "not owner")
}

fn get_timestamp() uses ctx: Ctx -> u256 {
    ctx.block_timestamp()
}
```

## Contract Intrinsics

These intrinsics relate to contract state and identity:

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `self_address()` | `Address` | This contract's address |
| `balance(addr)` | `u256` | ETH balance of address (in wei) |
| `self_balance()` | `u256` | This contract's ETH balance |
| `code_size(addr)` | `u256` | Size of code at address |
| `code_hash(addr)` | `u256` | Keccak256 hash of code at address |

### Usage

```fe ignore
fn get_contract_balance() -> u256 {
    self_balance()
}

fn is_contract(addr: Address) -> bool {
    code_size(addr) > 0
}
```

## Cryptographic Intrinsics

Hash functions and cryptographic operations:

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `keccak256(data)` | `u256` | Keccak-256 hash |
| `sha256(data)` | `u256` | SHA-256 hash |
| `ripemd160(data)` | `u256` | RIPEMD-160 hash |
| `ecrecover(hash, v, r, s)` | `Address` | Recover signer from signature |

### Usage

```fe ignore
fn hash_value(value: u256) -> u256 {
    keccak256(value)
}

fn verify_signature(
    message_hash: u256,
    v: u8,
    r: u256,
    s: u256,
    expected_signer: Address
) -> bool {
    let signer = ecrecover(message_hash, v, r, s)
    signer == expected_signer
}
```

## Assertion Intrinsics

Control flow for error handling:

| Intrinsic | Description |
|-----------|-------------|
| `assert(condition, message)` | Revert if condition is false |
| `revert` | Unconditionally revert execution |
| `todo()` | Placeholder that always reverts |

### Usage

```fe ignore
fn transfer(from: Address, to: Address, amount: u256) {
    assert(from != Address::zero(), "transfer from zero address")
    assert(to != Address::zero(), "transfer to zero address")
    assert(balance >= amount, "insufficient balance")

    if some_condition {
        revert
    }
}

fn not_implemented() {
    todo()
}
```

## Call Intrinsics

For calling other contracts:

| Intrinsic | Description |
|-----------|-------------|
| `call(addr, value, data)` | Call another contract |
| `staticcall(addr, data)` | Read-only call (no state changes) |
| `delegatecall(addr, data)` | Call using this contract's storage |

### Usage

```fe ignore
fn send_eth(to: Address, amount: u256) -> bool {
    let (success, _) = call(to, amount, [])
    success
}
```

## Memory Intrinsics

Low-level memory operations:

| Intrinsic | Description |
|-----------|-------------|
| `mload(offset)` | Load 32 bytes from memory |
| `mstore(offset, value)` | Store 32 bytes to memory |
| `msize()` | Current memory size |

### Notes

These are rarely needed in Fe as the compiler manages memory automatically.

## Storage Intrinsics

Direct storage access:

| Intrinsic | Description |
|-----------|-------------|
| `sload(slot)` | Load from storage slot |
| `sstore(slot, value)` | Store to storage slot |

### Notes

Fe's storage system abstracts over these. Use storage structs and effects instead.

## Log Intrinsics

Event emission:

| Intrinsic | Description |
|-----------|-------------|
| `log.emit(event)` | Emit an event to the transaction log |

### Usage

```fe ignore
struct TransferEvent {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

fn emit_transfer(from: Address, to: Address, value: u256) uses mut log: Log {
    log.emit(TransferEvent { from, to, value })
}
```

## Value Transfer

| Intrinsic | Description |
|-----------|-------------|
| `msg_value()` | ETH sent with the current call |

### Usage

```fe ignore
fn deposit() uses ctx: Ctx {
    let amount = ctx.msg_value()
    // Process deposit...
}
```

## Block Hash

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `block_hash(number)` | `u256` | Hash of a recent block (last 256 blocks) |

### Usage

```fe ignore
fn get_recent_block_hash(block_num: u256) -> u256 {
    block_hash(block_num)
}
```

## Summary

| Category | Intrinsics |
|----------|------------|
| Context | `caller`, `block_number`, `block_timestamp`, `chain_id`, etc. |
| Contract | `self_address`, `balance`, `code_size`, `code_hash` |
| Crypto | `keccak256`, `sha256`, `ecrecover` |
| Control | `assert`, `revert`, `todo` |
| Calls | `call`, `staticcall`, `delegatecall` |
| Events | `log.emit` |

## Best Practices

1. **Use effects instead of raw intrinsics** - Fe's effect system (`uses Ctx`, `uses Log`) provides safer access to intrinsics

2. **Avoid low-level storage/memory** - Let Fe manage these automatically

3. **Check ecrecover results** - Always verify the recovered address is not zero

4. **Be careful with block_hash** - Only works for the last 256 blocks

5. **Handle call failures** - External calls can fail; always check return values

---
title: Intrinsics Reference
description: Fe intrinsic functions
---

Intrinsics are built-in functions that provide direct access to EVM operations and low-level functionality. This appendix documents available intrinsics in Fe.

## Context Intrinsics

Execution-context information is exposed as methods on the `Ctx` effect. Any function that
declares `uses (ctx: Ctx)` can call them:

| Method | Returns | Description |
|--------|---------|-------------|
| `ctx.caller()` | `Address` | Address that called this contract |
| `ctx.block_number()` | `u256` | Current block number |
| `ctx.timestamp()` | `u256` | Current block timestamp (seconds since epoch) |
| `ctx.coinbase()` | `Address` | Current block miner/validator address |
| `ctx.prevrandao()` | `u256` | Block randomness (post-Merge; replaces difficulty) |
| `ctx.gaslimit()` | `u256` | Current block gas limit |
| `ctx.chainid()` | `u256` | Current chain ID |
| `ctx.origin()` | `Address` | Original transaction sender |
| `ctx.gasprice()` | `u256` | Gas price of the transaction |
| `ctx.gas()` | `u256` | Remaining gas for execution |

### Usage

```fe
fn only_owner(owner: Address) uses (ctx: Ctx) {
    assert!(ctx.caller() == owner, "not owner")
}

fn get_timestamp() -> u256 uses (ctx: Ctx) {
    ctx.timestamp()
}
```

## Contract Intrinsics

Contract state and identity are also `Ctx` methods:

| Method | Returns | Description |
|--------|---------|-------------|
| `ctx.address()` | `Address` | This contract's address |
| `ctx.balance(addr)` | `u256` | ETH balance of address (in wei) |
| `ctx.selfbalance()` | `u256` | This contract's ETH balance |
| `ctx.extcodesize(addr)` | `u256` | Size of code at address |
| `ctx.extcodehash(addr)` | `u256` | Keccak256 hash of code at address |

### Usage

```fe
fn get_contract_balance() -> u256 uses (ctx: Ctx) {
    ctx.selfbalance()
}

fn is_contract(addr: Address) -> bool uses (ctx: Ctx) {
    ctx.extcodesize(addr) > 0
}
```

## Cryptographic Intrinsics

Hash functions and signature recovery live in `std::evm::crypto`. The hash functions operate on a
**memory region** (offset and length), and the precompile-backed ones return a `Result`:

| Function | Returns | Description |
|----------|---------|-------------|
| `crypto::keccak256(offset, len)` | `u256` | Keccak-256 of a memory region |
| `crypto::sha256(offset, len)` | `Result<PrecompileError, u256>` | SHA-256 (precompile `0x02`) |
| `crypto::ripemd160(offset, len)` | `Result<PrecompileError, u256>` | RIPEMD-160 (precompile `0x03`) |
| `crypto::ecrecover(hash, v, r, s)` | `Result<PrecompileError, Option<u256>>` | Recover signer from signature (precompile `0x01`) |

Signature recovery takes plain `u256` scalars and returns a `Result`; the inner `Option` is `None`
for a non-canonical signature:

```fe
use std::evm::crypto

fn verify_signature(
    message_hash: u256,
    v: u256,
    r: u256,
    s: u256,
    expected_signer: u256,
) -> bool {
    match crypto::ecrecover(hash: message_hash, v: v, r: r, s: s) {
        Ok(maybe_signer) => {
            match maybe_signer {
                Some(signer) => signer == expected_signer
                None => false
            }
        }
        Err(_) => false
    }
}
```

The hash functions take a memory region rather than a value, so you first write bytes to memory
(through the `RawMem` effect) and then hash them:

```fe ignore
use std::evm::crypto

// `offset`/`len` describe bytes already written to EVM memory.
fn hash_region(offset: u256, len: u256) -> u256 {
    crypto::keccak256(offset, len)
}
```

## Assertion Intrinsics

Control flow for error handling:

| Intrinsic | Description |
|-----------|-------------|
| `assert!(condition[, message])` | Revert if condition is false |
| `revert` | Unconditionally revert execution |
| `todo()` | Placeholder that always reverts |

### Usage

```fe
fn transfer(from: Address, to: Address, amount: u256, balance: u256) {
    assert!(from.inner != 0)
    assert!(to.inner != 0)
    assert!(balance >= amount)
    //<hide>
    let _ = (from, to, amount, balance)
    //</hide>
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

```fe
#[event]
struct TransferEvent {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,
}

fn emit_transfer(from: own Address, to: own Address, value: u256) uses (log: mut Log) {
    log.emit(event: TransferEvent { from, to, value })
}
```

## Value Transfer

| Intrinsic | Description |
|-----------|-------------|
| `msg_value()` | ETH sent with the current call |

### Usage

```fe
fn deposit() uses (ctx: Ctx) {
    let amount = ctx.value()
    // Process deposit...
    //<hide>
    let _ = amount
    //</hide>
}
```

## Block Hash

| Method | Returns | Description |
|--------|---------|-------------|
| `ctx.blockhash(number)` | `u256` | Hash of a recent block (last 256 blocks) |

### Usage

```fe
fn get_recent_block_hash(block_num: u256) -> u256 uses (ctx: Ctx) {
    ctx.blockhash(block_num)
}
```

## Summary

| Category | Intrinsics |
|----------|------------|
| Context | `ctx.caller`, `ctx.block_number`, `ctx.timestamp`, `ctx.chainid`, etc. |
| Contract | `ctx.address`, `ctx.balance`, `ctx.extcodesize`, `ctx.extcodehash` |
| Crypto | `crypto::keccak256`, `crypto::sha256`, `crypto::ecrecover` |
| Control | `assert!`, `revert`, `todo` |
| Calls | `call`, `staticcall`, `delegatecall` |
| Events | `log.emit` |

## Best Practices

1. **Use effects instead of raw intrinsics** - Fe's effect system (`uses Ctx`, `uses Log`) provides safer access to intrinsics

2. **Avoid low-level storage/memory** - Let Fe manage these automatically

3. **Check ecrecover results** - Always verify the recovered address is not zero

4. **Be careful with block_hash** - Only works for the last 256 blocks

5. **Handle call failures** - External calls can fail; always check return values

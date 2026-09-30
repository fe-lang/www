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
**memory view** (`MemSpan`), and the precompile-backed ones return a `Result`:

| Function | Returns | Description |
|----------|---------|-------------|
| `crypto::keccak256(data)` | `u256` | Keccak-256 of a memory region |
| `crypto::sha256(data)` | `Result<PrecompileError, u256>` | SHA-256 (precompile `0x02`) |
| `crypto::ripemd160(data)` | `Result<PrecompileError, u256>` | RIPEMD-160 (precompile `0x03`) |
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

Hash a bounded view of bytes that you already own:

```fe
use std::evm::crypto
use std::abi::Bytes

fn hash_bytes(data: Bytes) -> u256 {
    crypto::keccak256(data.payload_span())
}

#[test]
fn hashes_empty_bytes() {
    assert!(hash_bytes(data: Bytes::empty()) ==
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470)
}
```

`payload_span()` excludes the ABI length word. `encoded_span()` includes the ABI representation and hashes different bytes.

For tightly packed encoding, Fe also provides `std::evm::packed::{encode_packed, keccak_packed, Packed}`. For EIP-712, use `crypto::eip712_digest(domain_separator, struct_hash)` (it requires a `uses (mem: mut RawMem)` effect) after constructing the domain separator and struct hash according to your schema. Packed encoding is distinct from ordinary ABI encoding; concatenating multiple variable-length values can be ambiguous.

## Integer Square Root

`core::num::isqrt` returns the square root of a `u256`, rounded down:

```fe
use core::num::isqrt

#[test]
fn integer_square_root() {
    assert!(isqrt(0) == 0)
    assert!(isqrt(15) == 3)
    assert!(isqrt(16) == 4)
}
```

## Assertion Intrinsics

Control flow for error handling:

| Intrinsic | Description |
|-----------|-------------|
| `assert!(condition[, message])` | Revert if condition is false |
| `revert(value)` | Revert with an ABI-encoded value (without an error selector) |
| `revert_error(error)` | Revert with a Solidity-compatible custom error |
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

## Calling Contracts

Use typed messages with the `Call` effect. `Address::call` forwards available gas, sends zero value, decodes the declared return type, and propagates reverts. Fe provides `Address::static` for a typed static call:

```fe
use std::abi::sol

msg TokenQuery {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
}

fn balance_at(token: Address, account: Address) -> u256 uses (call: Call) {
    token.static(TokenQuery::BalanceOf { account })
}
```

Use `call.call(addr, gas, value, message)` when gas and value need explicit control. `try_call` and `try_static` return a `CallOutcome` whose success flag and returndata can be inspected. `call_with_default` supplies a default only for a successful call with empty returndata; it still propagates reverts and strictly decodes nonempty data. For ERC20 interactions, prefer the dedicated [safe token helpers](/patterns/tokens/).

`std::evm::encode_msg_calldata(message)` produces a `MemBuffer` containing the selector and ABI arguments for a low-level call.

## Typed Memory

Fe uses `*T` for typed memory pointers and `core::ptr` for allocation. Initialize an allocation before reading it:

```fe
use core::ptr

#[test]
fn pointer_read_and_write() {
    let mut value: *u256 = ptr::alloc<u256>()
    *value = 41
    *value += 1
    assert!(*value == 42)
}
```

| Type | Purpose |
|------|---------|
| `MemSlice<T>` | Bounded read-only view of typed memory |
| `MemSpan` | Byte view, an alias for `MemSlice<u8>` |
| `MemBuffer` | Owned byte allocation with length and writable capacity |
| `FixedMemBuffer<N>` | Owned allocation with a compile-time byte size |

The old `MemPtr`, `MemoryInput`, `MemoryBytes`, and integer-address allocation APIs are removed. Pointer-bearing values cannot be stored in persistent or transient storage. A `ref T` borrow and a `*T` memory pointer serve different purposes; see [Ownership & Mutability](/foundations/ownership/).

A leading `*` starts a dereference statement. For multiline multiplication, leave the multiplication operator at the end of the preceding line.

## Storage Access

Use contract fields and `StorageMap` for ordinary storage. Low-level capabilities such as `RawStorage` and `RawMem` live under `std::evm`. Most opcode wrappers in `std::evm::ops` are internal to `std`; the exceptions are the pure `ops::byte(pos, value)` and `ops::signextend(byte, value)`, which are public and re-exported as `std::evm::byte` and `std::evm::signextend`.

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
| `ctx.value()` | ETH (in wei) sent with the current call |

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

## Sending ETH and Bounding Return Data

`Call::send_value` sends ETH with empty calldata and copies no returndata. It returns a `RawCallOutcome`; check `success()` explicitly. A failed transfer does not automatically revert the caller.

```fe
fn pay(recipient: Address, amount: u256) uses (ctx: Ctx, call: mut Call) {
    let outcome = call.send_value(addr: recipient, gas: ctx.gas(), value: amount)
    assert!(outcome.success(), "payment failed")
}
```

Update balances before transferring control to the recipient. Passing `ctx.gas()` requests the available gas, subject to the EVM's forwarding rules; the receiver can execute code and reenter.

`try_call_raw` forwards raw calldata and copies all return data. Use `try_call_into` or `try_static_into` to cap the copied data at a supplied buffer's capacity. Their `RawCallOutcome` still reports the full return-data length, so a truncated buffer must not be treated as a complete ABI response.

```fe
use core::ptr::MemBuffer
use std::abi::sol

msg Query {
    #[selector = sol("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
}

fn bounded_balance(token: Address, account: Address) -> u256 uses (call: Call) {
    let mut ret = MemBuffer::with_capacity(32)
    let outcome = call.try_static_into(
        addr: token, gas: 100000,
        message: Query::BalanceOf { account }, ret: mut ret,
    )
    assert!(outcome.success() && outcome.returndata_len() == 32)
    ret.span().word_at(0)
}
```

Static calls require only `uses (call: Call)`. Ordinary calls and value transfers require `uses (call: mut Call)`.

### Minimum Gas and Caller Reserve

`call_with_min_gas(addr, minimum, reserved, value, args)` prepays input-memory expansion and checks an overflow-safe EIP-150 budget immediately before calling. It returns `Result<InsufficientGas, RawCallOutcome>`: `Err` means the call was not attempted; `Ok` still needs a success check. It copies no returndata. The reserve is additional to EIP-150's retained fraction. Its conservative overhead assumption must be revisited if gas pricing changes.

```fe
use std::evm::calls::has_min_gas

#[test]
fn checks_gas_budget() {
    assert!(has_min_gas(available: 200000, minimum: 63000, reserved: 10000))
    assert!(!has_min_gas(available: 50000, minimum: 63000, reserved: 10000))
}
```

A rejected budget can be handled without attempting the external call:

```fe
use core::ptr::MemSpan

#[test]
fn refuses_unavailable_gas() uses (call: mut Call) {
    let outcome = call.call_with_min_gas(
        addr: Address::zero(), minimum: (1 << 255), reserved: 10000,
        value: 0, args: MemSpan::empty(),
    )
    match outcome {
        Result::Err(_) => {},
        Result::Ok(_) => assert!(false),
    }
}
```

## Hashing Words and Predicting Addresses

`keccak_words([..])` hashes complete ABI words. `create2_address` calculates an address from the deployer, salt, and initcode hash without deploying code. Packed encoding also supports custom-width Solidity integers such as `sol::Int24`.

```fe
use std::evm::{create2_address, keccak_words, checksum_address}

#[test]
fn address_helpers() {
    let predicted = create2_address(
        deployer: Address::zero(), salt: 0,
        init_code_hash: 0xbc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98a,
    )
    assert!(predicted.inner == 0x4d1a2e2bb4f88f0250f26ffff098b0b30b26bf38)
    assert!(keccak_words([1, 2]) != keccak_words([2, 1]))
    let address = Address::from_word_truncate((1 << 200) | 0xabc)
    assert!(address.inner == 0xabc)
    assert!(checksum_address(Address::zero()) == "0x0000000000000000000000000000000000000000")
}
```

`Address::from_word_truncate` explicitly keeps the low 160 bits. `checksum_address` instead requires a canonical address and returns ERC-55 checksum-cased text; it does not implement chain-dependent ERC-1191 checksums.

## Full-Precision Arithmetic

`core::num::mul_div(a, b, d)` computes floor division with a 512-bit intermediate product. `mul_div_ceil` rounds up. Division by zero or an unrepresentable quotient fails like checked arithmetic; `checked_mul_div` and `checked_mul_div_ceil` return `Option::None` instead. `full_mul` exposes the wide product, and `addmod`/`mulmod` are also available in `core::num`.

```fe
use core::num::{mul_div, mul_div_ceil, leading_zeros, trailing_zeros}

#[test]
fn arithmetic_helpers() {
    assert!(mul_div(1 << 200, 1 << 100, 1 << 100) == 1 << 200)
    assert!(mul_div_ceil(10, 10, 6) == 17)
    assert!(leading_zeros(0) == 256)
    assert!(trailing_zeros(8) == 3)
}
```

The bit-counting helpers accept `u256` and return 256 for zero. On the EVM, `leading_zeros` uses the CLZ instruction; deploying code that uses it requires an Osaka-compatible chain. Fe 26.4’s EVM tests use Osaka rules.

## Merkle Proofs

`std::evm::merkle` supports sorted-pair proofs (`verify` / `process_proof`) and positional proofs (`verify_indexed` / `process_indexed_proof`). Proof nodes are ordered from the leaf's sibling towards the root. The helpers read a `MemSlice<u256>`, `DynArray<u256>`, or `DynArray<Bytes32>` in place.

```fe
use std::abi::MemVec
use std::evm::{keccak_words, merkle}

#[test]
fn verifies_merkle_paths() {
    let leaf = keccak_words([7])
    let sibling = keccak_words([8])
    let mut nodes = MemVec<u256>::zeroed(1)
    nodes.set(index: 0, value: sibling)
    let proof = nodes.to_dyn_array()

    let sorted_root = merkle::hash_pair_sorted(leaf, sibling)
    assert!(merkle::verify(proof, root: sorted_root, leaf))
    assert!(!merkle::verify(proof, root: sorted_root, leaf: keccak_words([9])))

    let positional_root = keccak_words([leaf, sibling])
    assert!(merkle::verify_indexed(proof, root: positional_root, leaf, index: 0))
    assert!(!merkle::verify_indexed(proof, root: positional_root, leaf, index: 1))
}
```

Sorted pairs match OpenZeppelin's commutative Merkle proofs. Positional proofs instead use bit `i` of `index` to choose the side at level `i`; bits above the proof depth are ignored. Use the same tree shape and leaf encoding as the producer. These helpers accept an already hashed leaf and do not hash it for you. OpenZeppelin's standard tree double-hashes its ABI-encoded leaves; a raw 64-byte leaf preimage can be confused with a pair of internal nodes unless the leaf construction separates the two.

## Summary

| Category | Intrinsics |
|----------|------------|
| Context | `ctx.caller`, `ctx.block_number`, `ctx.timestamp`, `ctx.chainid`, etc. |
| Contract | `ctx.address`, `ctx.balance`, `ctx.extcodesize`, `ctx.extcodehash` |
| Crypto | `crypto::keccak256`, `crypto::sha256`, `crypto::ecrecover` |
| Control | `assert!`, `revert`, `todo` |
| Calls | `Address::call`, `Address::static`, `call.call`, `call.try_call`, `call.try_static`, `call.send_value` |
| Events | `log.emit` |

## Best Practices

1. **Use effects instead of raw intrinsics** - Fe's effect system (`uses Ctx`, `uses Log`) provides safer access to intrinsics

2. **Avoid low-level storage/memory** - Let Fe manage these automatically

3. **Check ecrecover results** - Handle both `Err` (precompile failure) and `Ok(None)` (invalid or non-canonical signature) before comparing the recovered signer

4. **Be careful with block_hash** - Only works for the last 256 blocks

5. **Handle call failures** - External calls can fail; always check return values

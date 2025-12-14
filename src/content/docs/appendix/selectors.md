---
title: Selector Calculation
description: How to compute function selectors
---

Function selectors are 4-byte identifiers that the EVM uses to route calls to the correct function. This appendix explains how selectors are calculated and provides common examples.

## What Are Selectors?

When you call a smart contract function, the EVM needs to know which function to execute. The first 4 bytes of the calldata contain the function selector—a unique identifier derived from the function signature.

```
Calldata: 0xa9059cbb000000000000000000000000...
          ^^^^^^^^
          Selector (4 bytes)
```

## Calculation Method

Selectors are calculated as the first 4 bytes of the Keccak-256 hash of the function signature:

```
selector = keccak256("functionName(type1,type2,...)")[0:4]
```

### Step-by-Step Example

For the ERC20 `transfer` function:

1. **Write the signature**: `transfer(address,uint256)`
2. **Hash it**: `keccak256("transfer(address,uint256)")`
3. **Take first 4 bytes**: `0xa9059cbb`

### Important Rules

1. **No spaces** - `transfer(address,uint256)` not `transfer(address, uint256)`
2. **No parameter names** - Just types
3. **Canonical type names** - Use `uint256` not `uint`
4. **Array syntax** - Use `uint256[]` for dynamic arrays

## Type Mappings

When calculating selectors, use these canonical type names:

| Fe Type | Signature Type |
|---------|---------------|
| `u256` | `uint256` |
| `u128` | `uint128` |
| `u64` | `uint64` |
| `u32` | `uint32` |
| `u16` | `uint16` |
| `u8` | `uint8` |
| `i256` | `int256` |
| `i128` | `int128` |
| `bool` | `bool` |
| `Address` | `address` |
| `String<N>` | `string` |
| `[T; N]` | `T[N]` (e.g., `uint256[3]`) |

## Common ERC20 Selectors

| Function | Signature | Selector |
|----------|-----------|----------|
| `name()` | `name()` | `0x06fdde03` |
| `symbol()` | `symbol()` | `0x95d89b41` |
| `decimals()` | `decimals()` | `0x313ce567` |
| `totalSupply()` | `totalSupply()` | `0x18160ddd` |
| `balanceOf(address)` | `balanceOf(address)` | `0x70a08231` |
| `transfer(address,uint256)` | `transfer(address,uint256)` | `0xa9059cbb` |
| `approve(address,uint256)` | `approve(address,uint256)` | `0x095ea7b3` |
| `allowance(address,address)` | `allowance(address,address)` | `0xdd62ed3e` |
| `transferFrom(address,address,uint256)` | `transferFrom(address,address,uint256)` | `0x23b872dd` |

## Common ERC721 Selectors

| Function | Signature | Selector |
|----------|-----------|----------|
| `balanceOf(address)` | `balanceOf(address)` | `0x70a08231` |
| `ownerOf(uint256)` | `ownerOf(uint256)` | `0x6352211e` |
| `safeTransferFrom(address,address,uint256)` | `safeTransferFrom(address,address,uint256)` | `0x42842e0e` |
| `transferFrom(address,address,uint256)` | `transferFrom(address,address,uint256)` | `0x23b872dd` |
| `approve(address,uint256)` | `approve(address,uint256)` | `0x095ea7b3` |
| `setApprovalForAll(address,bool)` | `setApprovalForAll(address,bool)` | `0xa22cb465` |
| `getApproved(uint256)` | `getApproved(uint256)` | `0x081812fc` |
| `isApprovedForAll(address,address)` | `isApprovedForAll(address,address)` | `0xe985e9c5` |

## Using Selectors in Fe

In Fe, you specify selectors explicitly in message definitions:

```fe ignore
msg Erc20 {
    #[selector = 0xa9059cbb]
    Transfer { to: Address, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: Address } -> u256,
}
```

### Why Explicit Selectors?

Fe requires explicit selectors because:

1. **ABI compatibility** - Ensures your contract matches expected interfaces
2. **Naming freedom** - Use Fe's snake_case while matching camelCase ERCs
3. **No ambiguity** - Clear what selector each message variant uses
4. **Verification** - Easy to verify against standards

## Computing Selectors

### Using Command Line Tools

With `cast` (from Foundry):

```bash
$ cast sig "transfer(address,uint256)"
0xa9059cbb
```

### Using Python

```python
from web3 import Web3

sig = "transfer(address,uint256)"
selector = Web3.keccak(text=sig)[:4].hex()
print(selector)  # 0xa9059cbb
```

### Using JavaScript

```javascript
const { keccak256, toUtf8Bytes } = require("ethers");

const sig = "transfer(address,uint256)";
const hash = keccak256(toUtf8Bytes(sig));
const selector = hash.slice(0, 10);  // "0xa9059cbb"
```

### Using Online Tools

Many online tools can compute selectors:
- Ethereum Signature Database: https://www.4byte.directory/
- Foundry's cast: https://book.getfoundry.sh/

### Future: Compile-Time Computation

:::note[Planned Feature]
Fe will provide a `sol_sig` const function for computing selectors at compile time:

```fe ignore
msg TokenMsg {
    #[selector = sol_sig("balanceOf(address)")]
    BalanceOf { account: Address } -> u256,
}
```

This will allow you to define selectors using the Solidity signature string directly, with no runtime cost—the computation happens at compile time.
:::

## Event Selectors

Events also have selectors (topic 0), but they use the full 32-byte hash:

```
event_selector = keccak256("Transfer(address,address,uint256)")
               = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
```

### Common ERC20 Event Selectors

| Event | Signature | Selector (topic 0) |
|-------|-----------|-------------------|
| Transfer | `Transfer(address,address,uint256)` | `0xddf252ad...` |
| Approval | `Approval(address,address,uint256)` | `0x8c5be1e5...` |

## Selector Collisions

Different function signatures can produce the same selector (collision). This is rare but possible:

```
transfer(address,uint256)     -> 0xa9059cbb
// Hypothetical collision:
someOtherFunction(bytes32)    -> 0xa9059cbb (if it existed)
```

When designing custom functions, verify your selectors don't collide with standard interfaces.

## Summary

| Concept | Description |
|---------|-------------|
| Selector | First 4 bytes of keccak256(signature) |
| Signature format | `functionName(type1,type2,...)` |
| No spaces | `transfer(address,uint256)` |
| Canonical types | `uint256` not `uint` |
| Event selector | Full 32-byte hash |

Explicit selectors in Fe ensure ABI compatibility while giving you naming freedom.

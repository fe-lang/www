---
title: Selectors
description: Function selectors for ABI compatibility
---

Selectors are 4-byte identifiers that tell the EVM which message variant to invoke. They enable ABI compatibility with the broader Ethereum ecosystem.

## What Are Selectors?

When a contract is called, the first 4 bytes of the calldata identify the function. This is the **selector**:

```
Calldata: 0xa9059cbb0000000000000000...
          ^^^^^^^^ selector (4 bytes)
                  ^^^^^^^^^^^^^^^^... arguments
```

Fe uses the same selector mechanism as Solidity, ensuring contracts can interoperate.

## The Selector Attribute

Specify selectors using the `#[selector]` attribute:

```fe
msg TokenMsg {
    #[selector = 0xa9059cbb]
    Transfer { to: u256, amount: u256 } -> bool,

    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}
```

### Selector Format

Selectors are specified as hexadecimal values:

```fe
msg Example {
    #[selector = 0xa9059cbb]  // Hex format (preferred)
    Transfer { to: u256, amount: u256 } -> bool,

    // Decimal format also valid: #[selector = 2835717307]
}
```

The value must fit in 4 bytes (u32).

## Required Selectors

Every message variant must have a selector:

```fe ignore
msg Example {
    // Error: missing selector
    NoSelector { value: u256 } -> bool,

    // Correct: has selector
    #[selector = 0x12345678]
    WithSelector { value: u256 } -> bool,
}
```

## Selector Uniqueness

Selectors must be unique across all recv blocks in a contract:

```fe ignore
msg MsgA {
    #[selector = 0x12345678]
    Operation { } -> bool,
}

msg MsgB {
    #[selector = 0x12345678]  // Same selector!
    AnotherOp { } -> bool,
}

contract Example {
    recv MsgA {
        Operation { } -> bool { true }
    }

    recv MsgB {
        AnotherOp { } -> bool { true }
        // Error: duplicate selector 0x12345678
    }
}
```

The compiler detects and reports selector conflicts.

## Standard Selectors

For ERC standards, use the established selectors. These are computed as the first 4 bytes of `keccak256(signature)`:

### ERC20 Selectors

| Function | Signature | Selector |
|----------|-----------|----------|
| transfer | `transfer(address,uint256)` | `0xa9059cbb` |
| approve | `approve(address,uint256)` | `0x095ea7b3` |
| transferFrom | `transferFrom(address,address,uint256)` | `0x23b872dd` |
| balanceOf | `balanceOf(address)` | `0x70a08231` |
| allowance | `allowance(address,address)` | `0xdd62ed3e` |
| totalSupply | `totalSupply()` | `0x18160ddd` |

### ERC721 Selectors

| Function | Signature | Selector |
|----------|-----------|----------|
| ownerOf | `ownerOf(uint256)` | `0x6352211e` |
| safeTransferFrom | `safeTransferFrom(address,address,uint256)` | `0x42842e0e` |
| approve | `approve(address,uint256)` | `0x095ea7b3` |
| getApproved | `getApproved(uint256)` | `0x081812fc` |

## Computing Selectors

Selectors are the first 4 bytes of `keccak256(function_signature)`:

```
keccak256("transfer(address,uint256)")
= 0xa9059cbb2ab09eb219583f4a59a5d0623ade346d962bcd4e46b11da047c9049b
       ^^^^^^^^
       Selector: 0xa9059cbb
```

Tools like `cast sig` from Foundry can compute these:

```bash
cast sig "transfer(address,uint256)"
# Output: 0xa9059cbb
```

:::note[Future: Compile-Time Selector Computation]
Fe will provide a `sol_sig` const function for computing selectors at compile time:

```fe ignore
msg TokenMsg {
    #[selector = sol_sig("balanceOf(address)")]
    BalanceOf { account: u256 } -> u256,
}
```

This will allow you to define selectors using the Solidity signature string directly, with no runtime cost. The computation happens at compile time.
:::

## Custom Selectors

For non-standard interfaces, you can use any unique 4-byte value:

```fe
msg CustomProtocol {
    #[selector = 0x00000001]
    Initialize { config: u256 },

    #[selector = 0x00000002]
    Process { data: u256 } -> bool,

    #[selector = 0x00000003]
    Query { id: u256 } -> u256,
}
```

Just ensure they don't conflict with selectors in other messages the contract handles.

## Why Explicit Selectors?

Fe requires explicit selectors rather than auto-generating them because:

1. **ABI compatibility**: Matching standard selectors ensures interoperability
2. **Naming freedom**: Fe uses snake_case conventions, but ERC standards use camelCase function names. Explicit selectors let you write idiomatic Fe while remaining fully compatible with Ethereum standards
3. **Clarity**: The selector is visible in the source code
4. **Stability**: Renaming a variant doesn't accidentally change its selector
5. **Verification**: Easy to verify against interface specifications

For example, you can name your variant `BalanceOf` or `balance_of`. It doesn't matter because the selector `0x70a08231` (derived from `balanceOf(address)`) is what the EVM uses for routing:

```fe
msg Erc20 {
    // Fe-style naming, but ABI-compatible with ERC20's balanceOf(address)
    #[selector = 0x70a08231]
    BalanceOf { account: u256 } -> u256,
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Selector | 4-byte function identifier |
| `#[selector = 0x...]` | Attribute to specify selector |
| Uniqueness | Selectors must be unique per contract |
| Standard selectors | Use established values for ERC compatibility |

---
title: ABI Compatibility
description: How Fe events map to EVM logs
---

Fe events compile to standard EVM logs, ensuring compatibility with existing Ethereum tooling. Understanding this mapping helps you design events that work seamlessly with indexers, explorers, and frontend libraries.

## EVM Log Structure

Every EVM log has two parts:

1. **Topics**: Up to 4 indexed values (32 bytes each)
2. **Data**: ABI-encoded non-indexed fields

```
Log Entry
├── topics[0]: Event signature hash (keccak256)
├── topics[1]: First indexed field
├── topics[2]: Second indexed field
├── topics[3]: Third indexed field
└── data: ABI-encoded remaining fields
```

## Event Signature

Topic 0 is always the keccak256 hash of the event signature:

```fe
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
```

The signature is: `Transfer(uint256,uint256,uint256)`

Topic 0 becomes: `keccak256("Transfer(uint256,uint256,uint256)")`

This matches Solidity's event encoding, ensuring tools recognize your events.

## Indexed Fields as Topics

Each `#[indexed]` field becomes a topic:

```fe
struct Transfer {
    #[indexed]
    from: u256,      // → topics[1]
    #[indexed]
    to: u256,        // → topics[2]
    amount: u256,    // → data
}
```

When emitting `Transfer { from: 0x123, to: 0x456, amount: 1000 }`:

| Component | Value |
|-----------|-------|
| topics[0] | `keccak256("Transfer(uint256,uint256,uint256)")` |
| topics[1] | `0x123` (from) |
| topics[2] | `0x456` (to) |
| data | ABI-encoded `1000` |

## Non-Indexed Fields in Data

Fields without `#[indexed]` are ABI-encoded into the data section:

```fe
struct Swap {
    #[indexed]
    sender: u256,
    amount_in: u256,    // → data
    amount_out: u256,   // → data
    timestamp: u256,    // → data
}
```

The data section contains: `abi.encode(amount_in, amount_out, timestamp)`

## Type Mapping

Fe types map to Solidity/ABI types:

| Fe Type | ABI Type | Notes |
|---------|----------|-------|
| `u256` | `uint256` | Direct mapping |
| `u128` | `uint128` | Direct mapping |
| `u64` | `uint64` | Direct mapping |
| `u32` | `uint32` | Direct mapping |
| `u16` | `uint16` | Direct mapping |
| `u8` | `uint8` | Direct mapping |
| `i256` | `int256` | Direct mapping |
| `bool` | `bool` | Direct mapping |

## ERC20 Compatibility Example

To emit ERC20-compatible events:

```fe
// ERC20 Transfer event
// Solidity: event Transfer(address indexed from, address indexed to, uint256 value)
struct Transfer {
    #[indexed]
    from: u256,      // address as u256
    #[indexed]
    to: u256,        // address as u256
    value: u256,
}

// ERC20 Approval event
// Solidity: event Approval(address indexed owner, address indexed spender, uint256 value)
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    value: u256,
}
```

These produce logs that standard ERC20 tools can parse.

## Working with Ethereum Tools

### ethers.js

```javascript
// Filter for Transfer events from a specific address
const filter = contract.filters.Transfer(fromAddress, null);
const logs = await contract.queryFilter(filter);

// Parse a Transfer event
const event = contract.interface.parseLog(log);
console.log(event.args.from, event.args.to, event.args.value);
```

### web3.js

```javascript
// Get past Transfer events
const events = await contract.getPastEvents('Transfer', {
    filter: { from: fromAddress },
    fromBlock: 0,
    toBlock: 'latest'
});
```

### The Graph

Fe events work with The Graph for indexing:

```graphql
type Transfer @entity {
  id: ID!
  from: Bytes!
  to: Bytes!
  value: BigInt!
}
```

## Event Signature Calculation

Calculate event signatures the same way as Solidity:

```
Event: Transfer(uint256 indexed from, uint256 indexed to, uint256 value)
Signature string: "Transfer(uint256,uint256,uint256)"
Topic 0: keccak256(signature string)
```

Note: The signature includes all parameter types, not just indexed ones.

## Matching Solidity Events

To emit events compatible with existing Solidity contracts:

```fe
// Match Solidity: event Transfer(address indexed from, address indexed to, uint256 value)
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    value: u256,  // Use 'value' to match Solidity field name
}
```

The struct field names don't affect ABI encoding—only the types and their order matter for the signature.

## Topic Limitations

Remember the EVM constraints:

| Constraint | Limit |
|------------|-------|
| Max topics | 4 (including signature) |
| Max indexed fields | 3 |
| Topic size | 32 bytes each |
| Data size | Unlimited |

Large values in indexed fields are hashed:
- Values ≤ 32 bytes: stored directly
- Values > 32 bytes: keccak256 hash stored

## Best Practices for ABI Compatibility

### Use Standard Event Names

Match established conventions:

```fe
// ERC20 standard names
struct Transfer { ... }
struct Approval { ... }

// ERC721 standard names
struct Transfer { ... }       // Same name, different context
struct ApprovalForAll { ... }
```

### Order Fields Correctly

Field order affects the signature:

```fe
// Order: indexed fields first, then data fields
struct Transfer {
    #[indexed]
    from: u256,      // First in signature
    #[indexed]
    to: u256,        // Second in signature
    amount: u256,    // Third in signature
}
// Signature: Transfer(uint256,uint256,uint256)
```

### Document Event Signatures

Include signatures in your documentation:

```fe
/// Transfer event
/// Signature: Transfer(uint256,uint256,uint256)
/// Topic 0: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
```

## Summary

| Concept | Description |
|---------|-------------|
| topics[0] | keccak256 of event signature |
| topics[1-3] | Indexed field values |
| data | ABI-encoded non-indexed fields |
| Signature | `EventName(type1,type2,...)` |
| Max indexed | 3 fields |

Fe events are fully ABI-compatible with Ethereum tooling. Design your events to match established standards when implementing common interfaces like ERC20 or ERC721.

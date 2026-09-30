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
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    amount: u256,
}
```

The signature is: `Transfer(address,address,uint256)`

Topic 0 becomes: `keccak256("Transfer(address,address,uint256)")`

This matches Solidity's event encoding, ensuring tools recognize your events.

## Indexed Fields as Topics

Each `#[indexed]` field becomes a topic:

```fe
#[event]
struct Transfer {
    #[indexed]
    from: Address,      // → topics[1]
    #[indexed]
    to: Address,        // → topics[2]
    amount: u256,    // → data
}
```

When emitting `Transfer { from: Address { inner: 0x123 }, to: Address { inner: 0x456 }, amount: 1000 }`:

| Component | Value |
|-----------|-------|
| topics[0] | `keccak256("Transfer(address,address,uint256)")` |
| topics[1] | `0x123` (from) |
| topics[2] | `0x456` (to) |
| data | ABI-encoded `1000` |

## Non-Indexed Fields in Data

Fields without `#[indexed]` are ABI-encoded into the data section:

```fe
#[event]
struct Swap {
    #[indexed]
    sender: Address,
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
| `Address` | `address` | Use for address fields, including indexed ones |

## ERC20 Compatibility Example

To emit ERC20-compatible events:

```fe
// ERC20 Transfer event
// Solidity: event Transfer(address indexed from, address indexed to, uint256 value)
#[event]
struct Transfer {
    #[indexed]
    from: Address,      // Solidity address
    #[indexed]
    to: Address,        // Solidity address
    value: u256,
}

// ERC20 Approval event
// Solidity: event Approval(address indexed owner, address indexed spender, uint256 value)
#[event]
struct Approval {
    #[indexed]
    owner: Address,
    #[indexed]
    spender: Address,
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
Event: Transfer(address indexed from, address indexed to, uint256 value)
Signature string: "Transfer(address,address,uint256)"
Topic 0: keccak256(signature string)
```

Note: The signature includes all parameter types, not just indexed ones.

## Matching Solidity Events

To emit events compatible with existing Solidity contracts:

```fe
// Match Solidity: event Transfer(address indexed from, address indexed to, uint256 value)
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
    value: u256,  // Use 'value' to match Solidity field name
}
```

The struct field names don't affect ABI encoding. The event struct name, field types, and their order determine the signature. A struct named `TransferEvent` has a different topic from `Transfer`.

## Topic Limitations

Remember the EVM constraints:

| Constraint | Limit |
|------------|-------|
| Max topics | 4 (including signature) |
| Max indexed fields | 3 |
| Topic size | 32 bytes each |

Fe adds its own limit on top of these: an event can have at most 16 non-indexed fields. The EVM itself does not limit the size of the data section.

Fe rejects unsupported indexed dynamic fields. Put dynamic values in the data section, or compute and index a fixed-size hash explicitly. Do not assume a Solidity-style automatic hash is generated for every indexed type.

## Best Practices for ABI Compatibility

### Use Standard Event Names

Match established conventions:

```fe ignore
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
#[event]
struct Transfer {
    #[indexed]
    from: Address,      // First in signature
    #[indexed]
    to: Address,        // Second in signature
    amount: u256,    // Third in signature
}
// Signature: Transfer(address,address,uint256)
```

### Document Event Signatures

Include signatures in your documentation:

```fe
/// Transfer event
/// Signature: Transfer(address,address,uint256)
/// Topic 0: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
#[event]
struct Transfer {
    #[indexed]
    from: Address,
    #[indexed]
    to: Address,
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

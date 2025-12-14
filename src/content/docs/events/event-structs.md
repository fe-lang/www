---
title: Event Structs
description: Defining events with indexed fields
---

Events in Fe are defined as structs with special attributes. When emitted, they create EVM logs that external systems can observe and filter.

## Basic Event Syntax

Define an event as a struct:

```fe
struct Transfer {
    from: u256,
    to: u256,
    amount: u256,
}

struct Approval {
    owner: u256,
    spender: u256,
    amount: u256,
}
```

These are regular structs that become events when emitted through the Log effect.

## Indexed Fields

The `#[indexed]` attribute marks fields that should become EVM log topics, making them filterable:

```fe
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}
```

With indexed fields:
- External tools can filter logs by these values
- The EVM stores them as separate topics
- Up to 3 fields can be indexed (EVM limitation)

### Why Index Fields?

Indexed fields enable efficient queries:

```fe
struct Transfer {
    #[indexed]
    from: u256,      // Filter: "all transfers FROM this address"
    #[indexed]
    to: u256,        // Filter: "all transfers TO this address"
    amount: u256,    // Just data, not filterable
}
```

External tools can then query:
- All transfers from a specific address
- All transfers to a specific address
- All transfers between two specific addresses

### Topic Limitations

The EVM allows at most 4 topics per log:
- Topic 0: Event signature (automatic)
- Topics 1-3: Your indexed fields

This means you can have at most 3 indexed fields:

```fe
// Valid: 3 indexed fields
struct ComplexEvent {
    #[indexed]
    field1: u256,
    #[indexed]
    field2: u256,
    #[indexed]
    field3: u256,
    data: u256,      // Non-indexed, goes in data section
}

// Invalid: too many indexed fields
struct TooManyIndexed {
    #[indexed]
    a: u256,
    #[indexed]
    b: u256,
    #[indexed]
    c: u256,
    #[indexed]
    d: u256,         // Error: exceeds 3 indexed fields
}
```

## Common Event Patterns

### Token Events

Standard token events follow ERC20/ERC721 conventions:

```fe
// ERC20 Transfer
struct Transfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    amount: u256,
}

// ERC20 Approval
struct Approval {
    #[indexed]
    owner: u256,
    #[indexed]
    spender: u256,
    amount: u256,
}

// ERC721 Transfer
struct NftTransfer {
    #[indexed]
    from: u256,
    #[indexed]
    to: u256,
    #[indexed]
    token_id: u256,
}
```

### Administrative Events

Events for contract administration:

```fe
struct OwnershipTransferred {
    #[indexed]
    previous_owner: u256,
    #[indexed]
    new_owner: u256,
}

struct Paused {
    account: u256,
}

struct Unpaused {
    account: u256,
}
```

### State Change Events

Events recording state changes:

```fe
struct Deposit {
    #[indexed]
    account: u256,
    amount: u256,
}

struct Withdrawal {
    #[indexed]
    account: u256,
    amount: u256,
}

struct ConfigUpdated {
    parameter: u256,
    old_value: u256,
    new_value: u256,
}
```

## Event Struct Guidelines

### Keep Events Focused

Each event should represent one logical occurrence:

```fe
// Good: specific events
struct Minted {
    #[indexed]
    to: u256,
    amount: u256,
}

struct Burned {
    #[indexed]
    from: u256,
    amount: u256,
}

// Less ideal: generic event
struct SupplyChanged {
    operation: u256,  // 0 = mint, 1 = burn
    account: u256,
    amount: u256,
}
```

### Choose Indexed Fields Wisely

Index fields you'll filter by:

```fe
struct Trade {
    #[indexed]
    trader: u256,      // Often filtered by trader
    #[indexed]
    token_in: u256,    // Often filtered by token
    #[indexed]
    token_out: u256,   // Often filtered by token
    amount_in: u256,   // Just data
    amount_out: u256,  // Just data
}
```

### Include Sufficient Context

Events should be self-contained for off-chain processing:

```fe
struct Swap {
    #[indexed]
    sender: u256,
    #[indexed]
    recipient: u256,
    amount0_in: u256,
    amount1_in: u256,
    amount0_out: u256,
    amount1_out: u256,
}
```

## Summary

| Concept | Description |
|---------|-------------|
| Event struct | Regular struct used for logging |
| `#[indexed]` | Makes field a filterable topic |
| Topic limit | Max 3 indexed fields per event |
| Non-indexed | Fields stored in log data section |

Events provide the foundation for off-chain indexing and dApp reactivity. Design them with your consumers in mind.

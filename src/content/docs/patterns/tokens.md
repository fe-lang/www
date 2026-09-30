---
title: Token Patterns
description: Fungible balances, NFT ownership, and external token calls
---

Token standards specify both a callable ABI and observable behavior, including events and failure cases. Matching function names alone is insufficient.

## Fungible Tokens

An ERC20-style ledger stores a balance per `Address`, a total supply, and an allowance per `(owner, spender)` pair. Transfers preserve total supply. Minting and burning change a balance and total supply together.

Read the [CoolCoin example](/examples/erc20/), then the focused sections on [allowances](/patterns/allowance/) and [supply](/patterns/supply/). Declare address parameters as `Address`: Fe checks message fields against `sol("...")` signatures.

## Non-Fungible Tokens

An NFT ledger maps each token ID to its owner. Authorization can come from the owner, a per-token approval, or an operator approval. A transfer must clear the per-token approval and update both owners' balances. An ERC721 implementation also needs interface detection and safe-transfer receiver checks. The [NFT example](/examples/erc721/) demonstrates the ownership core and identifies the remaining interface requirements.

## Calling External ERC20 Tokens

Fe provides helpers for tokens that return either `true` or no data:

```fe
use std::evm::erc20::{safe_transfer, safe_transfer_from, safe_approve}

fn pay(token: Address, recipient: Address, amount: u256)
uses (ctx: Ctx, call: mut Call) {
    safe_transfer(token, receiver: recipient, amount)
}

fn collect(token: Address, owner: Address, amount: u256)
uses (ctx: Ctx, call: mut Call) {
    safe_transfer_from(token, owner, receiver: ctx.address(), amount)
}

fn authorize(token: Address, spender: Address, amount: u256)
uses (ctx: Ctx, call: mut Call) {
    safe_approve(token, spender, amount)
}
```

These helpers propagate token reverts unchanged and reject a returned `false` or an empty successful response from an address without code. Such a rejection reverts with `revert("erc20: transfer failed")` (`transferFrom failed` / `approve failed` for the other helpers). As described in [Reverting](/errors/revert/), `revert(value)` ABI-encodes the string without the `Error(string)` selector, so wallets and tools won't decode it as a reason string. `safe_approve` does not reset an existing approval first; some tokens require an explicit approval of zero before a new nonzero amount.

A successful transfer call does not prove that the recipient received exactly `amount`. Fee-on-transfer and rebasing tokens need protocol-specific accounting. External token calls can also reenter the caller; finish local bookkeeping and apply the appropriate reentrancy protection before calling out.

## ERC-165 Interface Detection

`std::evm::erc165` provides bounded, read-only interface probes. `supports_interface` first verifies ERC-165 support (including rejection of the invalid interface ID); `supports_interface_unchecked` skips that prerequisite. A positive result is a contract's declaration, not proof of correct token behavior.

```fe
use std::evm::erc165::supports_interface

fn declares_erc721(token: Address) -> bool uses (call: Call) {
    supports_interface(token, interface_id: 0x80ac58cd)
}
```

## Handling Token Failures Explicitly

Fe 26.4 adds non-reverting ERC20 helpers: `try_transfer`, `try_transfer_from`, and `try_approve`. They copy at most 32 bytes of returndata and return a `TokenCall` outcome, so the caller can choose its own error:

```fe
use std::evm::{erc20, TokenCall}

#[error]
struct TokenPaymentFailed {}

fn pay_checked(token: Address, recipient: Address, amount: u256)
uses (ctx: Ctx, call: mut Call) {
    match erc20::try_transfer(token, receiver: recipient, amount) {
        TokenCall::Ok => {},
        TokenCall::Reverted => revert_error(TokenPaymentFailed {}),
        TokenCall::BadReturn => revert_error(TokenPaymentFailed {}),
        TokenCall::NoCode => revert_error(TokenPaymentFailed {}),
    }
}

#[test]
fn rejects_missing_token_code() uses (ctx: Ctx, call: mut Call) {
    let result = erc20::try_transfer(
        token: Address { inner: 0x123456 }, receiver: Address { inner: 7 }, amount: 1,
    )
    match result {
        TokenCall::NoCode => {},
        _ => assert!(false),
    }
}
```

`Ok` accepts a first return word equal to 1, or empty data from a token with code. `BadReturn` includes false, short, or malformed return values. `Reverted` means the call failed. Handling `BadReturn` without reverting does not undo state changes the token already made; choose that policy explicitly.

After `Reverted`, `bubble_last_revert()` can propagate the token's revert payload, or `copy_returndata()` can capture it. Do so before making another external call, which would replace the EVM returndata buffer.

### NFT and Multi-Token Calls

`erc721::try_transfer_from` returns `TokenCall` for `transferFrom`; it does not perform a safe-transfer receiver hook. `erc721::check_on_received` performs that hook and returns `ReceiverCheck`: `Accepted`, `WrongMagic`, `BadReturn`, `Reverted`, or `NoCode`. For an NFT receiver, `NoCode` means an EOA-style recipient and is normally accepted; for a token target, `TokenCall::NoCode` is a failure.

`erc1155::try_safe_transfer_from` and `try_safe_batch_transfer_from` call the token's safe-transfer entry points. The token implementation is responsible for its receiver callbacks. These ERC721/ERC1155 transfer helpers check target code before calling and classify success without decoding a boolean return.

# RepeatedSenderTrap — Drosera PoC Trap

## Overview

**RepeatedSenderTrap** is a proof-of-concept (PoC) trap designed for the **Drosera network**. It detects repeated senders in recent transactions on a blockchain sample (mocked for testing).

The trap works as follows:

1. `collect()` gathers a small array of addresses (simulating recent transaction senders).
2. `shouldRespond()` checks for any address appearing **3 or more times** in the collected sample.
3. If a repeated sender is found, the trap triggers a response via the **RepeatedSenderResponder** contract, emitting an alert event.

This trap is fully **Drosera-compatible**, stateless, and deterministic, making it ready for deployment on the **Hoodi testnet**.

---

## Features

* **Drosera Compatible**: Implements the `ITrap` interface with `collect()` and `shouldRespond()`.
* **Stateless & Pure**: No storage or external dependencies — deterministic behavior.
* **Test-Friendly**: Uses hardcoded addresses for immediate testing; can later integrate with a real Hoodi tx reader.
* **Event-Driven**: Alerts are emitted via a dedicated responder contract.
* **Simple & Lightweight**: Minimal gas usage and easy to extend for real network integration.

---

## Contracts

### 1. `RepeatedSenderTrap.sol`

* Implements `ITrap` interface.
* `collect()`: Returns a fixed array of addresses (memory).
* `shouldRespond(bytes[] calldata data)`: Checks for repeated addresses and returns a trigger signal if ≥3 repetitions exist.

### 2. `RepeatedSenderResponder.sol`

* Responds to the trap trigger by emitting:

```solidity
event RepeatedSenderAlert(address sender, uint256 count);
```

* Function:

```solidity
function respondWithRepeatedSenderAlert(address sender, uint256 count) external
```

* This payload is compatible with the Drosera relay response mechanism.

### 3. `DeployTrap.s.sol`

* Foundry deployment script that deploys both the trap and responder contracts on Hoodi.
* Logs the deployed contract addresses for easy TOML configuration.

---

## Deployment

1. Ensure **Foundry** is installed and configured.
2. Set environment variables:

```bash
export HOODI_RPC="https://ethereum-hoodi-rpc.publicnode.com"
export PRIVATE_KEY="<your_test_private_key>"
```

3. Build the contracts:

```bash
forge build
```

4. Deploy to Hoodi testnet:

```bash
forge script script/DeployTrap.s.sol:DeployTrap \
    --rpc-url $HOODI_RPC \
    --private-key $PRIVATE_KEY \
    --broadcast
```

* The script outputs the deployed **Trap** and **Responder** addresses.

---

## Drosera TOML Example

```toml
ethereum_rpc = "https://ethereum-hoodi-rpc.publicnode.com"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.repeated_sender]
path = "out/RepeatedSenderTrap.sol/RepeatedSenderTrap.json"
response_contract = "<RESPONDER_ADDRESS>"
response_function = "respondWithRepeatedSenderAlert(address,uint256)"
cooldown_period_blocks = 20
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 5
private_trap = true
whitelist = ["<YOUR_OPERATOR_ADDRESS>"]
```

> Replace `<RESPONDER_ADDRESS>` and `<YOUR_OPERATOR_ADDRESS>` with actual deployed addresses.

---

## Usage

1. Deploy contracts to Hoodi testnet.
2. Submit the trap to Drosera relay using the TOML configuration.
3. The relay calls `collect()` and `shouldRespond()` automatically.
4. When a repeated sender is detected, `RepeatedSenderResponder` emits `RepeatedSenderAlert`.

---

## Notes

* Current version uses a **hardcoded address array** for demonstration/testing.
* For real integration, `collect()` can fetch actual block transaction senders via a **Hoodi block reader contract**.
* Designed to be **safe, deterministic, and minimal gas** to fit Drosera’s trap standards.

---
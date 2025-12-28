# RepeatedSenderTrap — Drosera PoC Trap

## Overview

**RepeatedSenderTrap** is a proof-of-concept (PoC) trap for the **Drosera network**, detecting repeated senders in recent transactions.

### Behavior

1. `collect()` attempts to gather addresses from a Hoodi tx reader.

   * Gracefully handles missing reader; returns empty bytes until reader is deployed.
2. `shouldRespond()` detects addresses appearing **3 or more times**.
3. If a repeated sender is found, **RepeatedSenderResponder** emits an alert.

---

## Features

* **Drosera Compatible**: Implements `ITrap` interface.
* **Stateless & Pure**: No storage; deterministic behavior.
* **Test-Friendly**: Returns empty until reader deployed.
* **Event-Driven**: Alerts emitted via responder contract.
* **Safe & Lightweight**: Minimal gas, deploy-ready.

---

## Contracts

1. `RepeatedSenderTrap.sol` — implements trap logic.
2. `RepeatedSenderResponder.sol` — emits `RepeatedSenderAlert` when triggered.
3. `DeployTrap.s.sol` — Foundry deployment script.

---

## Deployment

```bash
export HOODI_RPC="https://ethereum-hoodi-rpc.publicnode.com"
export PRIVATE_KEY="<your_test_private_key>"

forge build

forge script script/DeployTrap.s.sol:DeployTrap \
    --rpc-url $HOODI_RPC \
    --private-key $PRIVATE_KEY \
    --broadcast
```

---

## Drosera TOML

```toml
[traps.repeated_sender]
path = "out/RepeatedSenderTrap.sol/RepeatedSenderTrap.json"
trap_contract = "0xa3c724233d90dE271b357e6919690f308fFd2Db7"
response_contract = "0xfF38560436f3eB6869d926b942a94773F8f9254a"
response_function = "respondWithRepeatedSenderAlert(address,uint256)"
cooldown_period_blocks = 20
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 1
private_trap = true
whitelist = ["0x43f89ee2ac9f93ed5e8913034bb9275630254d57"]
```

> Addresses updated to match your latest deployed contracts.

---

## Notes

* Currently uses a placeholder reader; `collect()` returns empty until deployed.
* Safe, deterministic, minimal gas — ready for Drosera PoC.

---
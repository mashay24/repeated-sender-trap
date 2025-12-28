// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IHoodiBlockTxs {
    function getBlockTxSenders(
        uint256 blockNumber,
        uint256 count
    ) external view returns (address[] memory);
}

contract RepeatedSenderTrap is ITrap {
    // Placeholder until Hoodi tx reader is deployed
    address constant HOODI_TX_READER =
        0x0000000000000000000000000000000000000000;

    /// @notice Collects sender addresses from Hoodi tx reader or returns empty if not deployed
    function collect() external view override returns (bytes memory) {
        address r = HOODI_TX_READER;
        if (r == address(0)) return bytes("");

        uint256 size;
        assembly {
            size := extcodesize(r)
        }
        if (size == 0) return bytes("");

        try IHoodiBlockTxs(r).getBlockTxSenders(block.number, 5) returns (
            address[] memory senders
        ) {
            return abi.encode(senders);
        } catch {
            return bytes("");
        }
    }

    /// @notice Checks for repeated senders in collected data
    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }

        address[] memory senders = abi.decode(data[0], (address[]));
        uint256 len = senders.length;

        for (uint256 i = 0; i < len; i++) {
            if (senders[i] == address(0)) continue;

            uint256 count = 1;
            for (uint256 j = i + 1; j < len; j++) {
                if (senders[i] == senders[j]) {
                    count++;
                }
            }

            if (count >= 3) {
                return (true, abi.encode(senders[i], count));
            }
        }

        return (false, bytes(""));
    }
}

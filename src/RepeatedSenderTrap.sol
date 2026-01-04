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
    /// @notice Hoodi transaction reader (can be zero for PoC)
    address public immutable hoodiTxReader;

    constructor(address _hoodiTxReader) {
        hoodiTxReader = _hoodiTxReader;
    }

    /// @notice Collects sender addresses from Hoodi tx reader
    /// @dev Gracefully returns empty bytes if reader is unset or invalid
    function collect() external view override returns (bytes memory) {
        address r = hoodiTxReader;
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
            address current = senders[i];
            if (current == address(0)) continue;

            uint256 count = 1;
            for (uint256 j = i + 1; j < len; j++) {
                if (current == senders[j]) {
                    count++;
                }
            }

            if (count >= 3) {
                return (true, abi.encode(current, count));
            }
        }

        return (false, bytes(""));
    }
}

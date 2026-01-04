// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RepeatedSenderTrap.sol";
import "../src/RepeatedSenderResponder.sol";

contract DeployTrap is Script {
    function run() external {
        vm.startBroadcast();

        RepeatedSenderResponder responder = new RepeatedSenderResponder();
        console.log("Responder deployed at:", address(responder));

        // For PoC: address(0)
        // For real deployment: actual HOODI_TX_READER address
        RepeatedSenderTrap trap = new RepeatedSenderTrap(address(0));
        console.log("Trap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}

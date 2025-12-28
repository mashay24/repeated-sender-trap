// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RepeatedSenderResponder {
    event RepeatedSenderAlert(address sender, uint256 count);

    /// @notice Emits an alert for repeated senders
    function respondWithRepeatedSenderAlert(
        address sender,
        uint256 count
    ) external {
        emit RepeatedSenderAlert(sender, count);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract GoodContract {
    mapping(address => uint256) public balances;

    // Update the `balances` mapping to include the new ETH deposited by msg.sender
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }
    // Send ETH worth `balances[msg.sender]` back to msg.sender

    function withdraw() public payable {
        // must have some ETH deposit ie ETH > 0
        require(balances[msg.sender] > 0);

        // attempt the transfer
        (bool sent,) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "Failed to send ether");
        // This code becomes unreachable because the contract's balance is drained
        // before user's balance could have been set to 0
        balances[msg.sender] = 0;
    }
}

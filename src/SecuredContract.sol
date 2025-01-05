// SPDX-License-Identifier:MIT
pragma solidity ^0.8.25;
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecuredContract {
    // We need 2 functions
    // 1. to add funds to the contract
    // 2. to withdraw from the contract

    // store the users and their balances
    mapping(address => uint256) public balances;

    function addBalance() public payable {
        require(msg.value > 0, "You have to send some ether");
        balances[msg.sender] += msg.value;
    }
    // using the Check-Effect-Interact method to curb re-entrancy

    // function withdraw (uint256 _amount) public {
    //     require(balances[msg.sender] > _amount, "Do you want to thief us?");
    //     balances[msg.sender] -= _amount;
    //     ( bool sent, ) = msg.sender.call{value: _amount}("");
    //     require( sent, "Could not send ETH");
    // }

    // using the Check-Effect-Interact method to curb re-entrancy
    function withdraw() public {
        uint256 _amount = balances[msg.sender];
        require(_amount > 0, "Do you want to theif us?");
        balances[msg.sender] = 0;
        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Error sending eth");
    }
}

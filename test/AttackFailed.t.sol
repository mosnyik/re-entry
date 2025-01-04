// SPDX-Licence-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Test } from "forge-std/Test.sol";
import { SecuredContract } from "../src/SecuredContract.sol";
import { BadContract } from "../src/BadContract.sol";

contract ReEntry is Test{
    //declare variables for instances of SecuredContract and BadContract
    BadContract public badContract;
    SecuredContract public securedContract;

    //get two addresses; treat one as an innocent user and the other as an attacker
    //these addresses created by expilcitly casting decimals to addresses
    address innocentUser = address(1);
    address attacker = address(2);

    function setUp() public {
        // Deploy the Good Contract
        securedContract = new SecuredContract();

        // Deploy the Bad Contract
        badContract = new BadContract(address(securedContract));

             //set the balances of the attacker and the innocent user to 100 ether
             deal(innocentUser, 100 ether);
             deal(attacker, 100 ether);
    }

    // function testAttack() public {
    //      // First value to deposit (10 ETH)
    //      uint firstDeposit = 10 ether;

    //     //for sending the next call will via the innocent user's address
    //     //prank is a cheatcode in foundry that allows us to impersonate someone
    //     vm.prank(innocentUser);

    //     // Innocent User deposits 10 ETH into SecuredContract
    //     securedContract.addBalance{value: firstDeposit}();

    //     // Check that at this point the SecuredContract's balance is 10 ETH
    //     assertEq(address(securedContract).balance, firstDeposit);

    //      //for sending the next call via the attacker's address
    //      vm.prank(attacker);

    //      // Attacker calls the `attack` function on BadContract and sends 1 ETH
    //      badContract.attack{value: 5 ether}();

    //      // Balance of the SecuredContract's address is now zero
    //      assertEq(address(securedContract).balance, 5);

    //     // Balance of BadContract is now 11 ETH (10 ETH stolen + 1 ETH from attacker)
    //     assertEq(address(badContract).balance, 15 ether);
    // }

        function testAttackFails() public {
        // Initial deposit by innocent user (10 ETH)
        uint256 firstDeposit = 10 ether;

        // Impersonate the innocent user
        vm.deal(innocentUser, 10 ether); // Fund innocentUser with 10 ETH
        vm.prank(innocentUser);
        securedContract.addBalance{value: firstDeposit}();

        // Ensure SecuredContract's balance is 10 ETH
        assertEq(address(securedContract).balance, firstDeposit);

        // Attacker attempts to attack by sending 5 ETH
        vm.deal(attacker, 5 ether); // Fund attacker with 5 ETH
        vm.prank(attacker);

        // This attack should fail due to re-entrancy protection
        vm.expectRevert("Error sending eth");
        badContract.attack{value: 5 ether}();

        // Ensure balances remain unaffected
        assertEq(address(securedContract).balance, firstDeposit, "SecuredContract balance changed!");
        assertEq(address(badContract).balance, 0, "BadContract gained funds!");

        // Innocent user can withdraw their funds successfully
        vm.prank(innocentUser);
        securedContract.withdraw();
        assertEq(address(securedContract).balance, 0, "Funds were not withdrawn!");
        assertEq(address(innocentUser).balance, 10 ether, "Innocent user did not get their funds!");
    }

}

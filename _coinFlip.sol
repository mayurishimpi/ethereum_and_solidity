// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract CoinFlip {
    address public player1;
    address public player2;
    uint public balance;

    constructor(address _player1, address _player2) {
        player1 = _player1;
        player2 = _player2;
    }

    // Function to add 1 ether from sender to the contract balance
    function addEther() public payable {

        balance += msg.value;
    }

    // Function to distribute the contract balance to player1 or player2 randomly
    function distributeEther() external {

        require(balance > 0, "No balance to distribute.");

        // Generate a random number (0 or 1)
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 2;



        // Distribute all the balance based on the random coin flip
        if (randomValue == 0) {
            payable(player1).transfer(balance);
        } else {
            payable(player2).transfer(balance);
        }

        // Reset the balance to 0
        balance = 0;

    }
}
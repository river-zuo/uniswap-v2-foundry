// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockKKToken is ERC20, Ownable {
    // address public minter;

    constructor(address initialOwner) ERC20("KK Token", "KK") Ownable(initialOwner) {
        // minter = initialOwner;
    }

    function mint(address to, uint256 amount) external {
        // require(msg.sender == minter, "Only minter");
        _mint(to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KKToken is ERC20, Ownable {

    constructor() ERC20("KK Token", "KK") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        // require(msg.sender == minter, "Only minter");
        _mint(to, amount);
    }
}

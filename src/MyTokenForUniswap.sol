// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenForUniswap is ERC20 {
    constructor(string memory name, string memory symbol, address recipient, uint256 amount) ERC20(name, symbol) {
        // 铸造100万个代币
        _mint(recipient, amount * 10 ** decimals());
    }
}

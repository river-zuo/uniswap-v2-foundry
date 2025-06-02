// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GovBank is Ownable{

    constructor(address _admin) Ownable(_admin) {}

    receive() external payable {}

    function withdraw(address to, uint256 amount) external onlyOwner {
        // payable(to).transfer(amount);
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Transfer failed");
    }
}

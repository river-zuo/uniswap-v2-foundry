// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract GovToken is ERC20Votes, ERC20Permit {
    constructor() ERC20("GovToken", "GT") ERC20Permit("GovToken") {
        _mint(msg.sender, 1_000_000 ether);
    }

    // 解决 nonces 冲突
    function nonces(
        address owner
    ) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    // 手动覆盖冲突函数
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

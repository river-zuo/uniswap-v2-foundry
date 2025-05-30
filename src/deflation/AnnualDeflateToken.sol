// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AnnualDeflateToken is ERC20, Ownable {
    
// 实现一个通缩的 Token （ERC20）， 用来理解 rebase 型 Token 的实现原理：
// 起始发行量为 1 亿，税后每过一年在上一年的发行量基础上下降 1%
// rebase 方法进行通缩
// balanceOf() 可反应通缩后的用户的正确余额。

    uint256 public constant REBASE_RATE = 99; // 每年减少1%
    uint256 public constant ANNUAL_REBASE_INTERVAL = 365 days;
    uint256 public constant RATE_PRECISION = 100;
    // uint256 public rebaseCount;

    uint256 currentFactor; // 初始因子为 1e18，表示初始状态下没有通缩
    uint256 public rebaseCount;

    uint256 public lastRebaseTime;
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        lastRebaseTime = block.timestamp;
        currentFactor = 10 ** decimals(); // 设置小数位数
        _mint(msg.sender, 100_000_000 * 10 ** decimals()); // 初始发行量为 1 亿
    }

    function balanceOf(address account) public view override virtual returns (uint256) {
        return super.balanceOf(account) * currentFactor / 10 ** decimals();
    }

    function mint(address account, uint256 amount) public onlyOwner {
        if (account == address(0)) {
            account = super.owner(); // 如果没有指定账户，则使用合约所有者地址
        }
        _mint(account, amount);
    }

    function rebase() external onlyOwner {
        require(block.timestamp >= lastRebaseTime + ANNUAL_REBASE_INTERVAL, "AnnualDeflateToken: rebase too soon");
        
        // 每次通缩减少 1%
        currentFactor = (currentFactor * REBASE_RATE) / RATE_PRECISION;
        rebaseCount++;
        lastRebaseTime = block.timestamp;
    }

}

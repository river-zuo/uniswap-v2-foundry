// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract OptionToken is ERC20, Ownable {
    address public immutable underlyingAsset; // ETH (WETH)
    address public immutable quoteAsset;      // USDT
    uint256 public immutable strikePrice;     // 单位：USDT，精度为 1e18
    uint256 public immutable expiry;          // 到期时间戳（秒）

    constructor(
        address _underlying,
        address _quote,
        uint256 _strikePrice,
        uint256 _expiry
    ) ERC20("ETH Call Option", "oETH") Ownable(msg.sender) {
        require(_expiry > block.timestamp, "Invalid expiry");
        underlyingAsset = _underlying;
        quoteAsset = _quote;
        strikePrice = _strikePrice;
        expiry = _expiry;
    }

    // 项目方发行期权
    function deposit(uint256 amount) external onlyOwner {
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    // 用户行权
    function exercise(uint256 amount) external {
        require(block.timestamp >= expiry && block.timestamp < expiry + 1 days, "Not in exercise window");

        uint256 cost = amount * strikePrice / 1e18;
        IERC20(quoteAsset).transferFrom(msg.sender, address(this), cost);

        _burn(msg.sender, amount);
        IERC20(underlyingAsset).transfer(msg.sender, amount);
    }

    function redeemExpired() external onlyOwner {
        require(block.timestamp >= expiry + 1 days, "Too early to redeem");

        uint256 balance = IERC20(underlyingAsset).balanceOf(address(this));
        IERC20(underlyingAsset).transfer(owner(), balance);
    }
}

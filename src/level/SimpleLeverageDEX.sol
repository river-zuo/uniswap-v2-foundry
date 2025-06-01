// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleLeverageDEX {
    uint public vK;
    uint public vETHAmount;
    uint public vUSDCAmount;

    IERC20 public USDC;

    struct PositionInfo {
        uint256 margin;       // 用户质押的保证金
        uint256 borrowed;     // 借来的 USDC 数量
        int256 position;      // 虚拟 ETH 仓位（正数多仓，负数空仓）
    }

    mapping(address => PositionInfo) public positions;

    constructor(address _usdc, uint _vEth, uint _vUSDC) {
        USDC = IERC20(_usdc);
        vETHAmount = _vEth;
        vUSDCAmount = _vUSDC;
        vK = vETHAmount * vUSDCAmount;
    }

    // 开仓：_margin 保证金，level 杠杆倍数，long true 为多仓
    function openPosition(uint256 _margin, uint level, bool long) external {
        require(positions[msg.sender].position == 0, "Position already open");

        USDC.transferFrom(msg.sender, address(this), _margin);

        uint256 amount = _margin * level;
        uint256 borrowAmount = amount - _margin;

        PositionInfo storage pos = positions[msg.sender];
        pos.margin = _margin;
        pos.borrowed = borrowAmount;

        if (long) {
            // 用总资金买 ETH，vAMM 买 ETH = USDC 入池，ETH 出池
            uint ethOut = getAmountOut(amount, vUSDCAmount, vETHAmount);
            vUSDCAmount += amount;
            vETHAmount -= ethOut;
            pos.position = int256(ethOut);
        } else {
            // 用总资金做空 ETH，vAMM 卖 ETH = ETH 入池，USDC 出池
            uint ethIn = getAmountIn(amount, vUSDCAmount, vETHAmount);
            vUSDCAmount -= amount;
            vETHAmount += ethIn;
            pos.position = -int256(ethIn);
        }

        // 更新虚拟池恒定乘积
        vK = vETHAmount * vUSDCAmount;
    }

    // 平仓：计算当前价格下的持仓价值，返还利润或扣除亏损
    function closePosition() external {
        PositionInfo storage pos = positions[msg.sender];
        require(pos.position != 0, "No open position");

        int256 pnl = calculatePnL(msg.sender);
        uint256 totalReturn;

        if (pnl >= 0) {
            totalReturn = pos.margin + uint256(pnl);
        } else {
            int256 loss = -pnl;
            require(loss < int256(pos.margin), "Loss exceeds margin");
            totalReturn = pos.margin - uint256(loss);
        }

        // 假设还清借款即可，协议不保留利息
        USDC.transfer(msg.sender, totalReturn);
        delete positions[msg.sender];
    }

    // 清算亏损过大的仓位
    function liquidatePosition(address _user) external {
        require(_user != msg.sender, "Cannot liquidate self");

        PositionInfo memory pos = positions[_user];
        require(pos.position != 0, "No open position");

        int256 pnl = calculatePnL(_user);
        if (pnl >= 0) return;

        uint256 loss = uint256(-pnl);
        require(loss > pos.margin * 80 / 100, "Not enough loss for liquidation");

        // 奖励清算人一部分剩余资金
        uint256 remaining = pos.margin > loss ? pos.margin - loss : 0;
        if (remaining > 0) {
            USDC.transfer(msg.sender, remaining / 10); // 10% 奖励
        }

        delete positions[_user];
    }

    // 根据当前虚拟价格计算 PnL
    function calculatePnL(address user) public view returns (int256) {
        PositionInfo memory pos = positions[user];
        if (pos.position == 0) return 0;

        uint price = vUSDCAmount * 1e18 / vETHAmount; // 精度为 1e18

        int256 value = (pos.position * int256(price)) / 1e18; // 当前价值（USDC 计价）

        if (pos.position > 0) {
            return value - int256(pos.borrowed);
        } else {
            return int256(pos.borrowed) + value; // value 为负值，加回
        }
    }

    // vAMM 定价函数
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint) {
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint) {
        return (reserveIn * amountOut) / (reserveOut - amountOut);
    }
}

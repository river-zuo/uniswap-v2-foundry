// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/level/SimpleLeverageDEX.sol";
import "src/MyTokenForUniswap.sol";

contract SimpleLeverageDEXTest is Test {
    SimpleLeverageDEX dex;
    MyTokenForUniswap usdc;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        usdc = new MyTokenForUniswap("Level_1USDC", "USDC", address(this), 1_000_000 * 1e6);
        dex = new SimpleLeverageDEX(address(usdc), 100 ether, 100_000 * 1e6);

        usdc.transfer(alice, 10_000 * 1e6);
        usdc.transfer(bob, 10_000 * 1e6);

        usdc.transfer(address(dex), 100_000 * 1e6);
    }

    function testOpenAndCloseLong() public {
        vm.startPrank(alice);
        usdc.approve(address(dex), type(uint).max);
        dex.openPosition(1000 * 1e6, 5, true); // 5x long

        int pnl = dex.calculatePnL(alice);
        assertTrue(pnl >= -int(1e6)); // 合理范围内的亏损或利润

        dex.closePosition();
        vm.stopPrank();
    }

    function testOpenAndCloseShort() public {
        vm.startPrank(bob);
        usdc.approve(address(dex), type(uint).max);
        dex.openPosition(1000 * 1e6, 3, false); // 3x short

        int pnl = dex.calculatePnL(bob);
        assertTrue(pnl >= -int(1e6));

        dex.closePosition();
        vm.stopPrank();
    }

    function testLiquidation() public {
        vm.startPrank(alice);
        usdc.approve(address(dex), type(uint).max);
        dex.openPosition(1000 * 1e6, 10, true); // 高杠杆

        // 模拟价格波动，导致清算
        // 手动操控 vAMM（暴力模拟）
        vm.stopPrank();
        // 提高 ETH price（卖 ETH）
        vm.prank(address(99)); // 模拟 admin 操作
        dex.vUSDCAmount(); // 调试时可打印

        // 触发清算
        vm.startPrank(bob);
        dex.liquidatePosition(alice);
        vm.stopPrank();
    }
}

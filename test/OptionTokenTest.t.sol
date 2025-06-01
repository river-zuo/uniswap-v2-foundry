// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/option/OptionToken.sol";
import "src/WETH9.sol";
import "src/MyTokenForUniswap.sol";

contract OptionTokenTest is Test {
    OptionToken public option;
    address public owner = address(1);
    address public user = address(2);

    address public WETH;
    address public USDT;

    function setUp() public {
        // 部署WETH和USDT代币合约
        WETH9 weth9 = new WETH9();
        MyTokenForUniswap usdt = new MyTokenForUniswap("USDT", "USDT", address(this), 1_000_000);
        WETH = address(weth9);
        USDT = address(usdt);
        // deal(owner, 10_000 ether); // 给owner一些ETH用于测试
        // 初始化WETH和USDT的初始余额
        // deal(WETH, owner, 100 ether);
        // deal(USDT, owner, 10000 ether);
        // deal(WETH, user, 10 ether);
        // deal(USDT, user, 1000 ether);
        // 部署OptionToken合约
        vm.startPrank(owner);
        // weth9.deposit{value: 1000 ether}();
        option = new OptionToken(WETH, USDT, 1800 ether, block.timestamp + 1 days);
        vm.stopPrank();
    }

    // 发行期权
    function testDepositAndMint() public {
        vm.startPrank(owner);
        deal(WETH, owner, 10 ether);
        IERC20(WETH).approve(address(option), 10 ether);
        option.deposit(10 ether);
        assertEq(option.balanceOf(owner), 10 ether);
        vm.stopPrank();
    }

    // 用户行权
    function testExercise() public {
        // 先发行期权
        vm.startPrank(owner);
        deal(WETH, owner, 1 ether);
        IERC20(WETH).approve(address(option), 1 ether);
        option.deposit(1 ether);
        option.transfer(user, 1 ether);
        vm.stopPrank();
        
        // 用户行权
        skip(1 days); // 跳到到期日
        vm.startPrank(user);
        deal(USDT, user, 1800 ether);
        IERC20(USDT).approve(address(option), 1800 ether);
        option.exercise(1 ether);
        assertEq(option.balanceOf(user), 0);
        assertEq(IERC20(WETH).balanceOf(user), 1 ether);
        vm.stopPrank();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/deflation/AnnualDeflateToken.sol";

contract AnnualDeflateTokenTest is Test {

    AnnualDeflateToken token;
    address userA = address(0x123);

    function setUp() public {
        // 部署 AnnualDeflateToken 合约
        token = new AnnualDeflateToken("Annual Deflate Token", "ADT");
        token.transfer(userA, 500 * 10 ** token.decimals()); // 转账给用户 A 500 万
    }

    function testDeflation() public {
        
        // 测试 rebase 方法
        uint256 balanceA_before = token.balanceOf(address(userA));
        console.log("User A's balance before rebase:", balanceA_before);
        vm.warp(block.timestamp + 365 days + 1); // 跳过一年
        token.rebase();
        uint256 balanceA_after = token.balanceOf(address(userA));
        console.log("User A's balance after rebase:", balanceA_after);
        assertEq(balanceA_after, balanceA_before * 99 / 100, "Balance should decrease by 1% after rebase");
        vm.expectRevert("AnnualDeflateToken: rebase too soon");
        token.rebase();

        // 再次测试 rebase 方法
        balanceA_before = token.balanceOf(address(userA));
        console.log("User A's balance before second rebase:", balanceA_before);
        vm.warp(block.timestamp + 365 days + 365 days + 1); // 再跳过一年
        token.rebase();
        balanceA_after = token.balanceOf(address(userA));
        console.log("User A's balance after second rebase:", balanceA_after);
        assertEq(balanceA_after, balanceA_before * 99 / 100, "Balance should decrease by 1% after second rebase");
    }

}

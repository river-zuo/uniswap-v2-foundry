// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/stake/StakingPool.sol";
import "../src/stake/MockKKToken.sol";

contract StakingPoolTest is Test  {
    StakingPool public pool;
    MockKKToken public kk;

    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        kk = new MockKKToken(address(this));

        
        pool = new StakingPool(address(kk));

        // 授权 StakingPool 合约为 KK Token minter
        kk.transferOwnership(address(pool));
        vm.prank(address(pool));
        kk.mint(address(this), 0); // 触发 minter 校验，Foundry mock trick
        // kk.mint(address(pool), 1000 ether); // 给 StakingPool 合约一些 KK Token 作为奖励池
        kk.mint(address(pool), 1000 ether);
    }

    // function testStakeAndClaimRewardsA() public {
    //     address user = address(0x123);
    //     vm.deal(user, 10 ether);

    //     vm.startPrank(user);
    //     pool.stake{value: 5 ether}();
    //     vm.warp(block.timestamp + 10);
    //     pool.claim();
    //     vm.stopPrank();
    // }

    function testStakeAndClaimRewards() public {
        vm.deal(alice, 10 ether);
        vm.startPrank(alice);
        pool.stake{value: 5 ether}();
        vm.stopPrank();

        skip(10); // 跳过 10 个区块

        vm.prank(alice);
        pool.claim();

        uint256 reward = kk.balanceOf(alice);
        assertEq(reward, 10 * 10 ether, "Incorrect KK reward"); // 10 区块 * 每区块 10 token
    }

    function testMultipleUsersFairDistribution() public {
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        // Alice 提前质押
        vm.startPrank(alice);
        pool.stake{value: 10 ether}();
        vm.stopPrank();

        skip(5); // 5 个区块过去

        // Bob 加入质押
        vm.startPrank(bob);
        pool.stake{value: 10 ether}();
        vm.stopPrank();

        skip(5); // 又过 5 个区块，共 10

        // Claim
        vm.prank(alice);
        pool.claim();

        vm.prank(bob);
        pool.claim();

        uint256 totalReward = kk.balanceOf(alice) + kk.balanceOf(bob);
        assertEq(totalReward, 10 * 10 ether, "Total rewards mismatch");

        assertGt(kk.balanceOf(alice), kk.balanceOf(bob), "Alice should get more");
    }

    function testUnstake() public {
        vm.deal(alice, 10 ether);

        vm.startPrank(alice);
        pool.stake{value: 2 ether}();
        skip(3);
        pool.unstake(1 ether);
        skip(2);
        pool.claim();
        vm.stopPrank();

        uint256 kkReward = kk.balanceOf(alice);
        assertGt(kkReward, 0, "Should receive reward");
        assertEq(pool.balanceOf(alice), 1 ether, "Remaining stake should be 1 ether");
    }

    function testRevertsOnExcessUnstake() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        pool.stake{value: 1 ether}();

        vm.expectRevert("Not enough staked");
        vm.prank(alice);
        pool.unstake(2 ether);
    }
}

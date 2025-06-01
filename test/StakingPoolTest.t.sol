// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "src/stake/StakingPool.sol";
import "src/stake/KKToken.sol";

contract StakingPoolTest is Test {
    StakingPool public stakingPool;
    KKToken public kkToken;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        kkToken = new KKToken();
        stakingPool = new StakingPool(address(kkToken));
        // kkToken.setMinter(address(stakingPool)); // 你需要在 KKToken 合约中实现这个方法，授权 stakingPool 铸币
        kkToken.transferOwnership(address(stakingPool));
    }

    function testStakeAndEarnSingleUser() public {
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        stakingPool.stake{value: 5 ether}();

        // 快进 10 个区块
        vm.roll(block.number + 10);

        vm.prank(user1);
        stakingPool.claim();

        uint256 reward = kkToken.balanceOf(user1);
        assertEq(reward, 10 * 10 ether); // 10 个区块 * 每区块 10 KK
    }

    function testMultipleUsersStakingAndRewards() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // user1 先质押
        vm.prank(user1);
        stakingPool.stake{value: 4 ether}();

        vm.roll(block.number + 5);

        // user2 后质押
        vm.prank(user2);
        stakingPool.stake{value: 6 ether}();

        vm.roll(block.number + 5);

        vm.roll(block.number + 1);

        // 两人领取奖励
        vm.prank(user1);
        stakingPool.claim();

        vm.roll(block.number + 5);

        vm.prank(user2);
        stakingPool.claim();

        // console.log("User1 KK Balance:", kkToken.balanceOf(user1));
        // console.log("User2 KK Balance:", kkToken.balanceOf(user2));
        // 检查奖励分配
        assertApproxEqAbs(kkToken.balanceOf(user1), 54 ether, 1e14);
        assertApproxEqAbs(kkToken.balanceOf(user2), 6 ether, 1e14);
    }

    // receive() external payable {
    //     // 允许合约接收ETH
    // }

    function testUnstakeAndClaim() public {
        vm.deal(user1, 5 ether);
        vm.prank(user1);
        stakingPool.stake{value: 5 ether}();

        vm.roll(block.number + 5);

        // 先领取，再退出
        vm.prank(user1);
        stakingPool.claim();

        vm.prank(user1);
        stakingPool.unstake(5 ether);

        // 再快进区块
        vm.roll(block.number + 5);

        // 没再质押，claim 应该报错或没有奖励
        vm.prank(user1);
        vm.expectRevert("no rewards");
        stakingPool.claim();
    }

    function testEarnedView() public {
        vm.deal(user1, 5 ether);
        vm.prank(user1);
        stakingPool.stake{value: 5 ether}();

        vm.roll(block.number + 10);

        uint256 earned = stakingPool.earned(user1);
        assertEq(earned, 10 * 10 ether);
    }
}

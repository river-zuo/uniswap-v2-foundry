// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IStaking, IToken} from "./IStakingInterfaces.sol";

contract StakingPool is IStaking {
    IToken public kkToken;

    uint256 public rewardPerBlock = 10 ether; // 每区块产出 10 个 KK（按 18 位精度）
    uint256 public lastRewardBlock;
    uint256 public accRewardPerShare; // 累积每份质押能获得多少奖励（乘上 1e12 精度）

    uint256 public totalStaked;

    struct UserInfo {
        uint256 amount;     // 质押的ETH数量
        uint256 rewardDebt; // 已经领取过的部分（用于计算未领取奖励）
    }

    mapping(address => UserInfo) public userInfo;

    constructor(address _kkToken) {
        kkToken = IToken(_kkToken);
        lastRewardBlock = block.number;
    }

    receive() external payable {
        stake();
    }

    function updatePool() public {
        if (block.number <= lastRewardBlock) return;

        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 blocks = block.number - lastRewardBlock;
        uint256 reward = blocks * rewardPerBlock;

        accRewardPerShare += reward * 1e12 / totalStaked;
        lastRewardBlock = block.number;
    }

    function stake() public payable override{
        require(msg.value > 0, "stake amount is 0");

        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        // 发放未领取奖励
        if (user.amount > 0) {
            uint256 pending = user.amount * accRewardPerShare / 1e12 - user.rewardDebt;
            if (pending > 0) {
                kkToken.mint(msg.sender, pending);
            }
        }

        user.amount += msg.value;
        user.rewardDebt = user.amount * accRewardPerShare / 1e12;
        totalStaked += msg.value;
    }

    function unstake(uint256 amount) external override {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "not enough staked");

        updatePool();

        uint256 pending = user.amount * accRewardPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            kkToken.mint(msg.sender, pending);
        }

        user.amount -= amount;
        user.rewardDebt = user.amount * accRewardPerShare / 1e12;
        totalStaked -= amount;

        // payable(msg.sender).transfer(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function claim() external override {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        uint256 pending = user.amount * accRewardPerShare / 1e12 - user.rewardDebt;
        require(pending > 0, "no rewards");

        user.rewardDebt = user.amount * accRewardPerShare / 1e12;
        kkToken.mint(msg.sender, pending);
    }

    function balanceOf(address account) external view override returns (uint256) {
        return userInfo[account].amount;
    }

    function earned(address account) external view override returns (uint256) {
        UserInfo storage user = userInfo[account];

        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastRewardBlock && totalStaked != 0) {
            uint256 blocks = block.number - lastRewardBlock;
            uint256 reward = blocks * rewardPerBlock;
            _accRewardPerShare += reward * 1e12 / totalStaked;
        }

        return user.amount * _accRewardPerShare / 1e12 - user.rewardDebt;
    }
}
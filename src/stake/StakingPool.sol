// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IStaking, IToken} from "./IStakingInterfaces.sol";

contract StakingPool is IStaking {
    
    IToken public immutable rewardToken; // KK Token
    uint256 public constant REWARD_PER_BLOCK = 10 ether; // 每个区块产出 10 个 KK，18 位精度

    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastBlock;
    }

    uint256 public totalStaked;
    mapping(address => StakerInfo) public stakers;

    constructor(address _rewardToken) {
        rewardToken = IToken(_rewardToken);
    }

    receive() external payable {
        stake();
    }

    function updateRewards(address account) internal {
        StakerInfo storage user = stakers[account];

        if (user.stakedAmount > 0) {
            uint256 blocks = block.number - user.lastBlock;
            uint256 totalReward = blocks * REWARD_PER_BLOCK;

            if (totalStaked > 0) {
                uint256 userShare = (totalReward * user.stakedAmount) / totalStaked;
                user.rewardDebt += userShare;
            }
        }

        user.lastBlock = block.number;
    }

    function stake() public payable override {
        require(msg.value > 0, "Must stake more than 0");

        updateRewards(msg.sender);

        stakers[msg.sender].stakedAmount += msg.value;
        totalStaked += msg.value;

        // （加分项）可将 msg.value 存入借贷市场赚利息
        // depositToLendingMarket(msg.value);
    }

    function unstake(uint256 amount) external override {
        StakerInfo storage user = stakers[msg.sender];
        require(user.stakedAmount >= amount, "Not enough staked");

        updateRewards(msg.sender);

        user.stakedAmount -= amount;
        totalStaked -= amount;

        payable(msg.sender).transfer(amount);

        // （可选）从借贷市场提取 ETH
        // withdrawFromLendingMarket(amount);
    }

    function claim() external override {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards");

        stakers[msg.sender].rewardDebt = 0;
        rewardToken.mint(msg.sender, reward);
    }

    function balanceOf(address account) external view override returns (uint256) {
        return stakers[account].stakedAmount;
    }

    function earned(address account) external view override returns (uint256) {
        StakerInfo memory user = stakers[account];
        if (user.stakedAmount == 0) return user.rewardDebt;

        uint256 blocks = block.number - user.lastBlock;
        uint256 totalReward = blocks * REWARD_PER_BLOCK;
        uint256 userShare = totalStaked > 0 ? (totalReward * user.stakedAmount) / totalStaked : 0;

        return user.rewardDebt + userShare;
    }
}

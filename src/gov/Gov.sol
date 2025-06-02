// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

contract Gov is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    constructor(IVotes _token)
        Governor("MyDAO")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(5) // 总票数需超过发行量的5%
    {}

    function votingDelay() public pure override returns (uint256) {
        return 1; // 1个区块后投票即生效
    }

    function votingPeriod() public pure override returns (uint256) {
        return 45818; // 投票周期
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {GovToken} from "src/gov/GovToken.sol";
import {Gov} from "src/gov/Gov.sol";
import {GovBank} from "src/gov/GovBank.sol";

contract GovTest is Test {
    GovToken token;
    Gov gov;
    GovBank bank;
    address alice = address(0x1);
    uint256 proposalId;

    function setUp() public {
        token = new GovToken();
        gov = new Gov(token);
        bank = new GovBank(address(gov));

        // 发行这些数量的token后，投票的票数就会不满足 5% 的阈值
        // token.mint(address(0x1111), 100_000_0000 ether);

        // 分发 token 并 delegate 投票权
        token.mint(alice, 100_000 ether);
        vm.prank(alice);
        token.delegate(alice);

        // delegate 生效需要至少一个区块
        vm.roll(block.number + 1); // 快进一个区块
    }

    function testFullProposalFlow() public {
        vm.deal(address(bank), 100 ether);
        assertEq(address(bank).balance, 100 ether);

        vm.startPrank(alice);

        // 准备提案参数
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        bytes memory callData = abi.encodeWithSignature("withdraw(address,uint256)", alice, 10 ether);
        targets[0] = address(bank);
        values[0] = 0;
        calldatas[0] = callData;
        // 提交提案
        proposalId = gov.propose(targets, values, calldatas, "withdraw 10ETH");
        console.log("Proposal ID:", proposalId);
        Gov.ProposalState state = gov.state(proposalId);
        console.log("Proposal State:", uint256(state));

        // 再快进两个区块，确保提案进入 Active 状态
        vm.roll(block.number + 2);

        state = gov.state(proposalId);
        console.log("Proposal State:", uint256(state));

        gov.castVote(proposalId, 1); // 成功投票

        vm.roll(block.number + gov.votingPeriod());

        state = gov.state(proposalId);
        console.log("Proposal State:", uint256(state));

        gov.execute(targets, values, calldatas, keccak256(bytes("withdraw 10ETH")));
        vm.stopPrank();

        state = gov.state(proposalId);
        console.log("Proposal State:", uint256(state));

        assertEq(alice.balance, 10 ether);
    }
    
}


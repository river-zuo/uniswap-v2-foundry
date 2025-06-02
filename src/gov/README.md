- 测试方法
[GovTest.t.sol](../../test/GovTest.t.sol)
- 测试日志
```
❯ forge test --match-contract GovTest -vvvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/GovTest.t.sol:GovTest
[PASS] testFullProposalFlow() (gas: 222010)
Logs:
  Proposal ID: 106333861061551550639333682635757986019804810114503755046007746930052132376830
  Proposal State: 0
  Proposal State: 1
  Proposal State: 4
  Proposal State: 7

Traces:
  [222010] GovTest::testFullProposalFlow()
    ├─ [0] VM::deal(GovBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], 100000000000000000000 [1e20])
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(100000000000000000000 [1e20], 100000000000000000000 [1e20]) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return] 
    ├─ [40169] Gov::propose([0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], [0], [0xf3fef3a300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000008ac7230489e80000], "withdraw 10ETH")
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 2
    │   ├─ emit ProposalCreated(proposalId: 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77], proposer: ECRecover: [0x0000000000000000000000000000000000000001], targets: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], values: [0], signatures: [""], calldatas: [0xf3fef3a300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000008ac7230489e80000], voteStart: 3, voteEnd: 45821 [4.582e4], description: "withdraw 10ETH")
    │   └─ ← [Return] 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]
    ├─ [0] console::log("Proposal ID:", 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [2009] Gov::state(106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]) [staticcall]
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 2
    │   └─ ← [Return] 0
    ├─ [0] console::log("Proposal State:", 0) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::roll(4)
    │   └─ ← [Return] 
    ├─ [2436] Gov::state(106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]) [staticcall]
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 4
    │   └─ ← [Return] 1
    ├─ [0] console::log("Proposal State:", 1) [staticcall]
    │   └─ ← [Stop] 
    ├─ [56782] Gov::castVote(106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77], 1)
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 4
    │   ├─ [5492] GovToken::getPastVotes(ECRecover: [0x0000000000000000000000000000000000000001], 3) [staticcall]
    │   │   └─ ← [Return] 100000000000000000000000 [1e23]
    │   ├─ emit VoteCast(voter: ECRecover: [0x0000000000000000000000000000000000000001], proposalId: 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77], support: 1, weight: 100000000000000000000000 [1e23], reason: "")
    │   └─ ← [Return] 100000000000000000000000 [1e23]
    ├─ [179] Gov::votingPeriod() [staticcall]
    │   └─ ← [Return] 45818 [4.581e4]
    ├─ [0] VM::roll(45822 [4.582e4])
    │   └─ ← [Return] 
    ├─ [20165] Gov::state(106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]) [staticcall]
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 45822 [4.582e4]
    │   ├─ [5543] GovToken::getPastTotalSupply(3) [staticcall]
    │   │   └─ ← [Return] 1100000000000000000000000 [1.1e24]
    │   └─ ← [Return] 4
    ├─ [0] console::log("Proposal State:", 4) [staticcall]
    │   └─ ← [Stop] 
    ├─ [48794] Gov::execute([0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], [0], [0xf3fef3a300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000008ac7230489e80000], 0xca02f2b8ae978850968aba28ce06e8a36e958fe55975d3f4cbe410c3bba6ec8c)
    │   ├─ [572] GovToken::clock() [staticcall]
    │   │   └─ ← [Return] 45822 [4.582e4]
    │   ├─ [1543] GovToken::getPastTotalSupply(3) [staticcall]
    │   │   └─ ← [Return] 1100000000000000000000000 [1.1e24]
    │   ├─ [37306] GovBank::withdraw(ECRecover: [0x0000000000000000000000000000000000000001], 10000000000000000000 [1e19])
    │   │   ├─ [3000] ECRecover::fallback{value: 10000000000000000000}()
    │   │   │   └─ ← [Return] 
    │   │   └─ ← [Stop] 
    │   ├─ emit ProposalExecuted(proposalId: 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77])
    │   └─ ← [Return] 106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    ├─ [685] Gov::state(106333861061551550639333682635757986019804810114503755046007746930052132376830 [1.063e77]) [staticcall]
    │   └─ ← [Return] 7
    ├─ [0] console::log("Proposal State:", 7) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(10000000000000000000 [1e19], 10000000000000000000 [1e19]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Return] 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 913.58µs (235.83µs CPU time)

Ran 1 test suite in 220.12ms (913.58µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
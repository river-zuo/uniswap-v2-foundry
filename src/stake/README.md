- 测试方法
[StakingPoolTest.t.sol](../../test/StakingPoolTest.t.sol)
- 测试日志
```
❯ forge test --match-contract StakingPoolTest -vvv
[⠊] Compiling...
[⠒] Compiling 1 files with Solc 0.8.28
[⠑] Solc 0.8.28 finished in 1.58s
Compiler run successful!

Ran 4 tests for test/StakingPoolTest.t.sol:StakingPoolTest
[PASS] testEarnedView() (gas: 74514)
[PASS] testMultipleUsersStakingAndRewards() (gas: 262409)
[PASS] testStakeAndEarnSingleUser() (gas: 174872)
[PASS] testUnstakeAndClaim() (gas: 165892)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 5.37ms (3.63ms CPU time)

Ran 1 test suite in 223.99ms (5.37ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```

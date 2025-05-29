- 测试文件
测试文件[FlashSwapArbitrageTest](../../test/FlashSwapArbitrageTest.sol)
- 测试日志
```
❯ forge test --match-contract FlashSwapArbitrageTest -vvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/FlashSwapArbitrageTest.sol:FlashSwapArbitrageTest
[PASS] testExecuteArbitrage() (gas: 187134)
Logs:
  Before Flash Arb: 0
  After Flash Arb: 49055009423959375950

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 23.54ms (1.24ms CPU time)

Ran 1 test suite in 254.23ms (23.54ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
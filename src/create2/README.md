- 测试用例日志
```
❯ forge test --match-contract ERC20FactoryTest -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 2 tests for test/ERC20FactoryTest.t.sol:ERC20FactoryTest
[PASS] testBuyMemeWithBetterPrice() (gas: 2553680)
Logs:
  before:  100000000000000000000
  after:  183291562238930659983

[PASS] testDeployAndAddLiquidity() (gas: 2507123)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 15.51ms (2.38ms CPU time)

Ran 1 test suite in 231.71ms (15.51ms CPU time): 2 tests passed, 0 failed, 0 skipped (2 total tests)
```

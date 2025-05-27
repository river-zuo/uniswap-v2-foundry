# 最小代理实现ERC20铸币工厂
- 工厂合约
ERC20FactoryContract.sol
- erc20模版合约
BaseERC20Template.sol
-测试合约
test/create2/ERC20FactoryContractTest.sol
# 测试日志
```
❯ forge test --match-contract ERC20Factory -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/create2/ERC20FactoryContractTest.sol:ERC20FactoryContractTest
[PASS] testDeployAndMint() (gas: 293740)
Logs:
  erc20 factory balance:  10
  minter balance:  999999999999999950
  creator balance:  1000000000000000040
  minter token:  100

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 717.33µs (232.33µs CPU time)

Ran 1 test suite in 124.02ms (717.33µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

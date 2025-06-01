- 测试方法
[SimpleLeverageDEXTest.t.sol](../../test/SimpleLeverageDEXTest.t.sol)
- 测试日志
```
❯ forge test --match-contract SimpleLeverageDEXTest -vvv
[⠊] Compiling...
[⠒] Compiling 1 files with Solc 0.8.28
[⠑] Solc 0.8.28 finished in 1.58s
Compiler run successful!

Ran 3 tests for test/SimpleLeverageDEXTest.t.sol:SimpleLeverageDEXTest
[PASS] testLiquidation() (gas: 145402)
[PASS] testOpenAndCloseLong() (gas: 113564)
[PASS] testOpenAndCloseShort() (gas: 113569)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 464.33µs (380.71µs CPU time)

Ran 1 test suite in 222.35ms (464.33µs CPU time): 3 tests passed, 0 failed, 0 skipped (3 total tests)
```
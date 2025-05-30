- 测试方法
[AnnualDeflateTokenTest.t.sol](../../test/AnnualDeflateTokenTest.t.sol)
- 测试日志
```
❯ forge test --match-contract AnnualDeflateTokenTest -vvv
[⠊] Compiling...
[⠆] Compiling 1 files with Solc 0.8.28
[⠰] Solc 0.8.28 finished in 1.28s
Compiler run successful!

Ran 1 test for test/AnnualDeflateTokenTest.t.sol:AnnualDeflateTokenTest
[PASS] testDeflation() (gas: 64277)
Logs:
  User A's balance before rebase: 500000000000000000000
  User A's balance after rebase: 495000000000000000000
  User A's balance before second rebase: 495000000000000000000
  User A's balance after second rebase: 490050000000000000000

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 365.25µs (114.25µs CPU time)

Ran 1 test suite in 226.02ms (365.25µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
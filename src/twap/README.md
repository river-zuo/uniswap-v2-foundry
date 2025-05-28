- MemeTWAP测试用例
```
test/MemeTWAPTest.t.sol
```
查看合约文件 👉[MemeTWAPTest](../../test/MemeTWAPTest.t.sol)
- MemeTWAP测试日志
```
❯ forge test --match-contract MemeTWAPTest -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/MemeTWAPTest.t.sol:MemeTWAPTest
[PASS] testMemeTWAP() (gas: 2772463)
Logs:
  Deployed token address: 0x4f81992FCe2E1846dD528eC0102e6eE1f61ed3e2
  pair address: 0x4f81992FCe2E1846dD528eC0102e6eE1f61ed3e2
  firset purchase done
  second purchase done
  third purchase done
  TWAP (Token per ETH): 1148602315334619745501545735397448
  TWAP (ETH per Token): 26054544187694414839690215141057657

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 16.32ms (1.77ms CPU time)

Ran 1 test suite in 231.15ms (16.32ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

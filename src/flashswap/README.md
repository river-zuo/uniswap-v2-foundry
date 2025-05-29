- 测试文件
测试文件[FlashSwapArbitrageTest](../../test/FlashSwapArbitrageTest.sol)
- 测试日志
```
❯ forge test --match-contract FlashSwapArbitrageTest -vvvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/FlashSwapArbitrageTest.sol:FlashSwapArbitrageTest
[PASS] testExecuteArbitrage() (gas: 187700)
Logs:
  Before Flash Arb: 0
  After Flash Arb: 49055009423959375950

Traces:
  [239891] FlashSwapArbitrageTest::testExecuteArbitrage()
    ├─ [0] VM::startPrank(SHA-256: [0x0000000000000000000000000000000000000002])
    │   └─ ← [Return] 
    ├─ [2515] MyTokenForUniswap::balanceOf(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b]) [staticcall]
    │   └─ ← [Return] 0
    ├─ [0] VM::recordLogs()
    │   └─ ← [Return] 
    ├─ [213637] FlashArb::executeArb(MyTokenForUniswap: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], MyTokenForUniswap: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], 50000000000000000000 [5e19], 0, true)
    │   ├─ [241] UniswapV2Router02::factory() [staticcall]
    │   │   └─ ← [Return] UniswapV2Factory: [0xe73bc5BD4763A3307AB5F8F126634b7E12E3dA9b]
    │   ├─ [241] UniswapV2Router02::factory() [staticcall]
    │   │   └─ ← [Return] UniswapV2Factory: [0xB267C5f8279A939062A20d29CA9b185b61380f10]
    │   ├─ [2600] UniswapV2Factory::getPair(MyTokenForUniswap: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], MyTokenForUniswap: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1]) [staticcall]
    │   │   └─ ← [Return] UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875]
    │   ├─ [193717] UniswapV2Pair::swap(50000000000000000000 [5e19], 0, FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 0x0000000000000000000000000000000000000000000000000000000000000001)
    │   │   ├─ [29608] MyTokenForUniswap::transfer(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875], to: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ [136796] FlashArb::uniswapV2Call(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 50000000000000000000 [5e19], 0, 0x0000000000000000000000000000000000000000000000000000000000000001)
    │   │   │   ├─ [449] UniswapV2Pair::token0() [staticcall]
    │   │   │   │   └─ ← [Return] MyTokenForUniswap: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]
    │   │   │   ├─ [381] UniswapV2Pair::token1() [staticcall]
    │   │   │   │   └─ ← [Return] MyTokenForUniswap: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1]
    │   │   │   ├─ [24325] MyTokenForUniswap::approve(UniswapV2Router02: [0x8Ba41269ed69496c07bea886c300016A0BA8FB5E], 50000000000000000000 [5e19])
    │   │   │   │   ├─ emit Approval(owner: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], spender: UniswapV2Router02: [0x8Ba41269ed69496c07bea886c300016A0BA8FB5E], value: 50000000000000000000 [5e19])
    │   │   │   │   └─ ← [Return] true
    │   │   │   ├─ [71510] UniswapV2Router02::swapExactTokensForTokens(50000000000000000000 [5e19], 0, [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459, 0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 1748393386 [1.748e9])
    │   │   │   │   ├─ [2517] UniswapV2Pair::getReserves() [staticcall]
    │   │   │   │   │   └─ ← [Return] 10000000000000000000000 [1e22], 20000000000000000000000 [2e22], 1748393386 [1.748e9]
    │   │   │   │   ├─ [8323] MyTokenForUniswap::transferFrom(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], UniswapV2Pair: [0xa85b9dB8EB142DfCc32590b3d1a8e04D25a21Edf], 50000000000000000000 [5e19])
    │   │   │   │   │   ├─ emit Transfer(from: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: UniswapV2Pair: [0xa85b9dB8EB142DfCc32590b3d1a8e04D25a21Edf], value: 50000000000000000000 [5e19])
    │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   ├─ [49828] UniswapV2Pair::swap(0, 99205460778021562510 [9.92e19], FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 0x)
    │   │   │   │   │   ├─ [27608] MyTokenForUniswap::transfer(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 99205460778021562510 [9.92e19])
    │   │   │   │   │   │   ├─ emit Transfer(from: UniswapV2Pair: [0xa85b9dB8EB142DfCc32590b3d1a8e04D25a21Edf], to: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 99205460778021562510 [9.92e19])
    │   │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   │   ├─ [515] MyTokenForUniswap::balanceOf(UniswapV2Pair: [0xa85b9dB8EB142DfCc32590b3d1a8e04D25a21Edf]) [staticcall]
    │   │   │   │   │   │   └─ ← [Return] 10050000000000000000000 [1.005e22]
    │   │   │   │   │   ├─ [515] MyTokenForUniswap::balanceOf(UniswapV2Pair: [0xa85b9dB8EB142DfCc32590b3d1a8e04D25a21Edf]) [staticcall]
    │   │   │   │   │   │   └─ ← [Return] 19900794539221978437490 [1.99e22]
    │   │   │   │   │   ├─ emit Sync(reserve0: 10050000000000000000000 [1.005e22], reserve1: 19900794539221978437490 [1.99e22])
    │   │   │   │   │   ├─ emit Swap(sender: UniswapV2Router02: [0x8Ba41269ed69496c07bea886c300016A0BA8FB5E], amount0In: 50000000000000000000 [5e19], amount1In: 0, amount0Out: 0, amount1Out: 99205460778021562510 [9.92e19], to: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b])
    │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   └─ ← [Return] [50000000000000000000 [5e19], 99205460778021562510 [9.92e19]]
    │   │   │   ├─ emit Step1()
    │   │   │   ├─ emit Step2(amount0: 50000000000000000000 [5e19], amount1: 99205460778021562510 [9.92e19])
    │   │   │   ├─ emit Step2(amount0: 50000000000000000000 [5e19], amount1: 50150451354062186560 [5.015e19])
    │   │   │   ├─ [7708] MyTokenForUniswap::transfer(UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875], 50150451354062186560 [5.015e19])
    │   │   │   │   ├─ emit Transfer(from: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875], value: 50150451354062186560 [5.015e19])
    │   │   │   │   └─ ← [Return] true
    │   │   │   ├─ [515] MyTokenForUniswap::balanceOf(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b]) [staticcall]
    │   │   │   │   └─ ← [Return] 49055009423959375950 [4.905e19]
    │   │   │   ├─ [22808] MyTokenForUniswap::transfer(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 49055009423959375950 [4.905e19])
    │   │   │   │   ├─ emit Transfer(from: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 49055009423959375950 [4.905e19])
    │   │   │   │   └─ ← [Return] true
    │   │   │   └─ ← [Stop] 
    │   │   ├─ [515] MyTokenForUniswap::balanceOf(UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875]) [staticcall]
    │   │   │   └─ ← [Return] 29950000000000000000000 [2.995e22]
    │   │   ├─ [515] MyTokenForUniswap::balanceOf(UniswapV2Pair: [0x6C068273f3Cebe6574A340c7723221f082743875]) [staticcall]
    │   │   │   └─ ← [Return] 10050150451354062186560 [1.005e22]
    │   │   ├─ emit Sync(reserve0: 29950000000000000000000 [2.995e22], reserve1: 10050150451354062186560 [1.005e22])
    │   │   ├─ emit Swap(sender: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], amount0In: 0, amount1In: 50150451354062186560 [5.015e19], amount0Out: 50000000000000000000 [5e19], amount1Out: 0, to: FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b])
    │   │   └─ ← [Stop] 
    │   └─ ← [Stop] 
    ├─ [515] MyTokenForUniswap::balanceOf(FlashArb: [0x2e234DAe75C793f67A35089C9d99245E1C58470b]) [staticcall]
    │   └─ ← [Return] 49055009423959375950 [4.905e19]
    ├─ [0] console::log("Before Flash Arb:", 0) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] console::log("After Flash Arb:", 49055009423959375950 [4.905e19]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    └─ ← [Return] 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 3.56ms (277.04µs CPU time)

Ran 1 test suite in 5.98s (3.56ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
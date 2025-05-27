# Uniswap V2 源代码分析与部署
- 核心源码注解
```
lib/v2-core/contracts/UniswapV2Factory.sol
lib/v2-core/contracts/UniswapV2Pair.sol
```
- UniswapFactory部署脚本及部署日志
```
script/DeployLegacyUniswapFactory.s.sol

❯ forge script script/DeployLegacyUniswapFactory.s.sol --rpc-url http://localhost:8545 --broadcast -vvv
[⠊] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Logs ==
  UniswapV2Factory deployed at: 0x553BED26A78b94862e53945941e4ad6E4F2497da
  tokenA deployed at: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
  tokenB deployed at: 0x34A1D3fff3958843C43aD80F30b94c510645C316
  Pair created at: 0xfEd41486be18b8c53ceF64BcE6d7c11387a85eEc
```
- UniswapV2Router02部署脚本及部署日志
```
script/DeployUniswapV2Router02.s.sol

❯ forge script script/DeployUniswapV2Router02.s.sol --rpc-url http://localhost:8545 --broadcast -vvv
[⠊] Compiling...
[⠑] Compiling 1 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 678.24ms
Compiler run successful!
Script ran successfully.

== Logs ==
  WETH9 deployed at: 0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519
  LegacyUniswapV2Router02 deployed at: 0xCe85503De9399D4dECa3c0b2bb3e9e7CFCBf9C6B
```

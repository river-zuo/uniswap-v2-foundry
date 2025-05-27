// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/BaseERC20.sol";
import "src/WETH9.sol";

interface ILegacyFactoryDeployer {
    function deploy(address feeToSetter) external returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DeployLegacyUniswapFactory is Script {
    function run() public {
        // address feeToSetter = vm.envAddress("FEE_TO_SETTER");
        address feeToSetter = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        vm.startBroadcast();
        // 部署 LegacyFactoryDeployer (0.5.16)
        address deployer = 0x3Aa5ebB10DC797CAC828524e59A333d0A371443c;

        // 调用 Legacy 部署器部署 UniswapV2Factory
        address factory = ILegacyFactoryDeployer(deployer).deploy(feeToSetter);
        WETH9 weth9 = new WETH9();

        BaseERC20 tokenA = new BaseERC20("TokenA", "TKA");
        BaseERC20 tokenB = new BaseERC20("TokenB", "TKB");
        address tokenAAddress = address(tokenA);
        address tokenBAddress = address(tokenB);
        address pair = IUniswapV2Factory(factory).createPair(tokenAAddress, tokenBAddress);

        vm.stopBroadcast();
        console2.log("WETH9 deployed at:", address(weth9));
        console2.log("tokenA deployed at:", tokenAAddress);
        console2.log("tokenB deployed at:", tokenBAddress);
        // console2.log("Deployer:", deployer);
        console2.log("UniswapV2Factory deployed at:", factory);
        // console2.log("INIT_CODE_PAIR_HASH:", factory.INIT_CODE_PAIR_HASH());
    }
}
// ❯ forge create --private-key $local_private_key --rpc-url http://127.0.0.1:8545 --broadcast LegacyFactoryDeployer
// [⠊] Compiling...
// No files changed, compilation skipped
// Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
// Deployed to: 0x3Aa5ebB10DC797CAC828524e59A333d0A371443c
// Transaction hash: 0xb6dcca209704546cbf1677281a9167bf6274b740a1203725defd70bb3e8d9fa7

// ✅ 准备部署者账户
// ✅ 部署 LegacyFactoryDeployer 合约
// ✅ 使用 deploy 方法创建 UniswapV2Factory 实例
// ✅ 调用 setFeeTo 设置费用接收地址 (可选)
// ✅ 为每对代币调用 createPair 方法
// ✅ 为每个交易对添加初始流动性
// ✅ 验证合约代码到区块浏览器


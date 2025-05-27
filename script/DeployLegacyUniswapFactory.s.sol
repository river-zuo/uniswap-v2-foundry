// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/BaseERC20.sol";

interface ILegacyFactoryDeployer {
    function deploy(address feeToSetter) external returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DeployLegacyUniswapFactory is Script {
    function run() public {
        // address feeToSetter = vm.envAddress("FEE_TO_SETTER");
        address feeToSetter = vm.envAddress("FEE_TO_SETTER");
        vm.startBroadcast();
        // 部署 LegacyFactoryDeployer (0.5.16)
        address deployer = 0xc6e7DF5E7b4f2A278906862b61205850344D4e7d;

        // 调用 Legacy 部署器部署 UniswapV2Factory
        address factory = ILegacyFactoryDeployer(deployer).deploy(feeToSetter);
        

        BaseERC20 tokenA = new BaseERC20("TokenA", "TKA");
        BaseERC20 tokenB = new BaseERC20("TokenB", "TKB");
        address tokenAAddress = address(tokenA);
        address tokenBAddress = address(tokenB);
        address pair = IUniswapV2Factory(factory).createPair(tokenAAddress, tokenBAddress);

        vm.stopBroadcast();

        console2.log("UniswapV2Factory deployed at:", factory);
        console2.log("tokenA deployed at:", tokenAAddress);
        console2.log("tokenB deployed at:", tokenBAddress);
        console2.log("Pair created at:", pair);
    }
}
// ❯ forge create --private-key $local_private_key --rpc-url http://127.0.0.1:8545 --broadcast LegacyFactoryDeployer
// [⠊] Compiling...
// No files changed, compilation skipped
// Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
// Deployed to: 0xc6e7DF5E7b4f2A278906862b61205850344D4e7d
// Transaction hash: 0x9bf2b40bffbe4f9921ce3721569095001abd0b3bf08a160390e9361694beb21a


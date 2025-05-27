// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/WETH9.sol";

interface ILegacyUniswapV2Router02Deployer {
    function deploy(address factory, address weth) external returns (address);
}

contract DeployUniswapV2Router02 is Script {
    
    function run() public {
        vm.startBroadcast();
        address factoryAddr = 0x553BED26A78b94862e53945941e4ad6E4F2497da;
        address router02Deployer = 0x59b670e9fA9D0A427751Af201D676719a970857b; // LegacyUniswapV2Router02Deployer address

        WETH9 weth9 = new WETH9();
        address routerV2 = ILegacyUniswapV2Router02Deployer(router02Deployer).deploy(factoryAddr, address(weth9));
        vm.stopBroadcast();
        console2.log("WETH9 deployed at:", address(weth9));
        console2.log("LegacyUniswapV2Router02 deployed at:", routerV2);
    }
}



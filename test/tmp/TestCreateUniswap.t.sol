// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {IUniswapV2Factory, IUniswapV2Pair, 
IUniswapV2Router02, ILegacyUniswapV2Router02Deployer, ILegacyFactoryDeployer} from "src/UniswapV2Interfaces.sol";
import "src/WETH9.sol";

contract TestCreateUniswap is Test {
    // ERC20FactoryContract factory;
    // BaseERC20Template baseTokenTemplate;
    IUniswapV2Router02 router;

    address user = address(2);

    function setUp() public {
        string memory sepolia = "http://127.0.0.1:8545";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);

        address deployer = 0x09635F643e140090A9A8Dcd712eD6285858ceBef;
        // 调用 Legacy 部署器部署 UniswapV2Factory
        address uniswapFactor = ILegacyFactoryDeployer(deployer).deploy(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

        address uniswapFactor2 = ILegacyFactoryDeployer(deployer).deploy(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

        console.log("uniswapFactor: ", uniswapFactor);
        console.log("uniswapFactor2: ", uniswapFactor2);

        WETH9 weth9 = new WETH9();
        WETH9 weth9_2 = new WETH9();
        address factoryAddr = uniswapFactor;
        address router02Deployer = 0x67d269191c92Caf3cD7723F116c85e6E9bf55933; // LegacyUniswapV2Router02Deployer address

        address routerV2 = ILegacyUniswapV2Router02Deployer(router02Deployer).deploy(factoryAddr, address(weth9));
        address routerV2_2 = ILegacyUniswapV2Router02Deployer(router02Deployer).deploy(uniswapFactor2, address(weth9_2));

        console.log("routerV2: ", routerV2);
        console.log("routerV2_2: ", routerV2_2);

        
    }

    function testA() public {

    }

}

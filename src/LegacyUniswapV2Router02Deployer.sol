// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "v2-periphery/contracts/UniswapV2Router02.sol";

contract LegacyUniswapV2Router02Deployer {
    
    function deploy(address _factory, address _weth) public returns (address) {
        UniswapV2Router02 router02 = new UniswapV2Router02(_factory, _weth);
        return address(router02);
    }
}

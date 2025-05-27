// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "v2-core/contracts/UniswapV2Factory.sol";

contract LegacyFactoryDeployer {
    function deploy(address _feeToSetter) public returns (address) {
        UniswapV2Factory factory = new UniswapV2Factory(_feeToSetter);
        return address(factory);
    }
}

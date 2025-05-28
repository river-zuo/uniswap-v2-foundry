// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface ILegacyUniswapV2Pair {
    function getInitCodeHash() external pure returns (bytes32);
}

contract GetInitHash is Script {
    function run() public {
        // vm.startBroadcast();
        address pairAddr = 0x7a2088a1bFc9d81c55368AE168C2C02570cB814F;
        bytes32 initCodeHash = ILegacyUniswapV2Pair(pairAddr).getInitCodeHash();
        // vm.stopBroadcast();
        console.logBytes32(initCodeHash);

        // 0x62aa3208743efde0d9d6d83b130198f3568ebefe627e5361a4153910b671ed7a
        // 0x8e530cef796dd6514461ca150e88a1b89f8b4e6d0f3ac650ea22a75ef6a96f5c
    }
}

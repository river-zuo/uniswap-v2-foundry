// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV2Pair} from "src/UniswapV2Interfaces.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MemeTWAPOracle {

    using Math for uint256;
    
    struct Observation {
        uint32 blockTimestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }

    receive() external payable {}

    mapping(address => Observation) public pairObservations;

    function observePair(address pairAddress) public {
        // IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        // (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = pair.getReserves();
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = getCurrentCumulativePrices(pairAddress);
        pairObservations[pairAddress] = Observation(blockTimestamp, price0Cumulative, price1Cumulative);
    }

    function getTWAP(address pairAddress, bool isToken0InToken1) public view returns (uint twap) {
        Observation memory obs = pairObservations[pairAddress];
        require(obs.blockTimestamp > 0, "No observation recorded");

        // (uint currentPrice0Cumulative, uint currentPrice1Cumulative, uint32 currentTimestamp) = IUniswapV2Pair(pairAddress).getReserves();
        (uint currentPrice0Cumulative, uint currentPrice1Cumulative, uint32 currentTimestamp) = getCurrentCumulativePrices(pairAddress);

        uint32 timeElapsed = currentTimestamp - obs.blockTimestamp;
        require(timeElapsed > 0, "Time has not elapsed");

        if (isToken0InToken1) {
            twap = (currentPrice1Cumulative - obs.price1Cumulative) / timeElapsed;
        } else {
            twap = (currentPrice0Cumulative - obs.price0Cumulative) / timeElapsed;
        }
    }


    function getCurrentCumulativePrices(address pairAddress) internal view returns (
        uint price0Cumulative,
        uint price1Cumulative,
        uint32 blockTimestamp
    ) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        price0Cumulative = pair.price0CumulativeLast();
        price1Cumulative = pair.price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        blockTimestamp = uint32(block.timestamp);

        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;

            // 模拟 UQ112x112.encode(reserve1).uqdiv(reserve0)
            uint price0 = (uint(reserve1) << 112) / reserve0;
            uint price1 = (uint(reserve0) << 112) / reserve1;

            price0Cumulative += price0 * timeElapsed;
            price1Cumulative += price1 * timeElapsed;
        }
    }

    // function testMultipleObservations() public {
    //     // 多次 observe + warp 模拟复杂场景
    //     for (uint i = 0; i < 5; i++) {
    //         twapOracle.observePair(address(pair));
    //         vm.warp(block.timestamp + 3600); // 每小时一次
    //         router.swapExactETHForTokens{value: 0.5 ether}(0, path, user, block.timestamp + 3600);
    //     }

    //     uint average = twapOracle.getTWAP(address(pair), false);
    //     console.log("Average price over 5 hours:", average);
    // }

}
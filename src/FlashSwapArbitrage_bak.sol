// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router02 } from "src/UniswapV2Interfaces.sol";

contract FlashSwapArbitrage_bak {
    using SafeERC20 for IERC20;
    
    address private factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    // 执行闪电兑换套利
    function arbitrage(
        address tokenA,
        address tokenB,
        uint amountAOutMin,
        uint amountBOutMin
    ) external {
        // 获取PoolA地址
        address pairAddress = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pairAddress != address(0), "Pair does not exist");
        
        // 获取储备量
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pairAddress).getReserves();
        
        // 确定token顺序
        address token0 = IUniswapV2Pair(pairAddress).token0();
        address token1 = IUniswapV2Pair(pairAddress).token1();
        
        // 计算需要闪贷的数量
        uint amountToSwap;
        if (token0 == tokenA && token1 == tokenB) {
            amountToSwap = calculateOptimalSwapAmount(reserve0, reserve1, IERC20(tokenA).balanceOf(pairAddress));
        } else if (token0 == tokenB && token1 == tokenA) {
            amountToSwap = calculateOptimalSwapAmount(reserve1, reserve0, IERC20(tokenA).balanceOf(pairAddress));
        } else {
            revert("Wrong pair reserves");
        }
        
        // 存储初始代币A余额
        uint tokenABalanceBefore = IERC20(tokenA).balanceOf(address(this));
        
        // 根据token顺序确定swap参数
        uint swapAmount0 = (token0 == tokenA) ? amountToSwap : 0;
        uint swapAmount1 = (token1 == tokenA) ? amountToSwap : 0;
        
        // 通过闪电兑换获取代币A
        bytes memory data = abi.encode(msg.sender, pairAddress, tokenA, tokenB);
        IUniswapV2Pair(pairAddress).swap(
            swapAmount0, 
            swapAmount1, 
            address(this), 
            data
        );
        
        // 确认获利
        uint tokenABalanceAfter = IERC20(tokenA).balanceOf(address(this));
        require(tokenABalanceAfter > tokenABalanceBefore, "No profit made");
        
        // 将利润发送给调用者
        uint profit = tokenABalanceAfter - tokenABalanceBefore;
        IERC20(tokenA).transfer(msg.sender, profit);
    }
    
    // 计算最优的兑换数量
    function calculateOptimalSwapAmount(uint112 reserveA, uint112 reserveB, uint totalSupply)
        internal 
        pure 
        returns (uint) 
    {
        // 这里使用简单的计算方式，在实际应用中应使用更复杂的算法
        return reserveA / 2;
    }

    // Uniswap V2回调函数
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        // 解析数据
        (address trader, address pairB, address tokenA, address tokenB) = abi.decode(data, (address, address, address, address));
        
        // 确保调用者是交易对
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        
        // 获取当前交易对的储备量
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(msg.sender).getReserves();
        
        // 计算应偿还的数量（包含费用）
        uint amountOwed;
        if (token0 == tokenA) {
            // 使用储备金公式计算: amountIn = (amountOut * reserveIn * 1000) / (reserveOut - amountOut) + 1
            amountOwed = (amount1 * reserve0 * 1000) / (reserve1 - amount1) + 1;
        } else {
            // 使用储备金公式计算: amountIn = (amountOut * reserveIn * 1000) / (reserveOut - amountOut) + 1
            amountOwed = (amount0 * reserve1 * 1000) / (reserve0 - amount0) + 1;
        }
        
        // 获取PoolB地址
        address pairAddressB = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pairAddressB == pairB, "Invalid pairB address");
        
        // 获取PoolB的储备量
        (uint112 reserveB0, uint112 reserveB1, ) = IUniswapV2Pair(pairB).getReserves();
        
        // 计算兑换率
        uint amountOut;
        if (token0 == tokenA) {
            // 使用从PoolA获得的TokenA在PoolB中兑换TokenB
            // 公式: amountOut = amountIn * reserveOut / reserveIn
            amountOut = (amountOwed * reserveB1 * 997) / (reserveB0 * 1000 + amountOwed * 997);
            
            // 在PoolB中兑换TokenB
            IUniswapV2Pair(pairB).swap(
                0, 
                amountOut, 
                address(this), 
                new bytes(0) // 空数据
            );
        } else {
            // 使用从PoolA获得的TokenB在PoolB中兑换TokenA
            // 公式: amountOut = amountIn * reserveOut / reserveIn
            amountOut = (amountOwed * reserveB0 * 997) / (reserveB1 * 1000 + amountOwed * 997);
            
            // 在PoolB中兑换TokenA
            IUniswapV2Pair(pairB).swap(
                amountOut, 
                0, 
                address(this), 
                new bytes(0) // 空数据
            );
        }
        
        // 偿还贷款
        if (token0 == tokenA) {
            IERC20(tokenA).safeTransfer(msg.sender, amountOwed);
        } else {
            IERC20(tokenB).safeTransfer(msg.sender, amountOwed);
        }
    }
    
    // 接收ETH回调
    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Pair, IUniswapV2Router02, IUniswapV2Factory, IUniswapV2Callee} from "src/UniswapV2Interfaces.sol";

contract FlashArb is IUniswapV2Callee {
    
    IUniswapV2Router02 public routerA;
    IUniswapV2Router02 public routerB;

    event Step1();
    event Step2(uint amount0, uint amount1);
    event Step3();

    constructor(address _routerA, address _routerB) {
        routerA = IUniswapV2Router02(_routerA);
        routerB = IUniswapV2Router02(_routerB);
    }

    function executeArb(
        address token0,
        address token1,
        uint amount0,
        uint amount1,
        bool fromAtoB
    ) external {
        address factoryA = routerA.factory();
        address factoryB = routerB.factory();
        // 从工厂A拿token0，借入闪电贷，再在工厂B中swap回token1
        address pair = IUniswapV2Factory(fromAtoB ? factoryA : factoryB).getPair(token0, token1);
        require(pair != address(0), "Pair doesn't exist");

        IUniswapV2Pair(pair).swap(
            amount0,
            amount1,
            address(this),
            abi.encode(fromAtoB) // 传递方向
        );
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        bool fromAtoB = abi.decode(data, (bool));

        address[] memory path = new address[](2);
        path[0] = amount0 > 0 ? IUniswapV2Pair(msg.sender).token0() : IUniswapV2Pair(msg.sender).token1();
        path[1] = amount0 > 0 ? IUniswapV2Pair(msg.sender).token1() : IUniswapV2Pair(msg.sender).token0();

        uint amountBorrowed = amount0 > 0 ? amount0 : amount1;
        IERC20(path[0]).approve(address(fromAtoB ? routerB : routerA), amountBorrowed);

        uint[] memory amounts = (fromAtoB ? routerB : routerA).swapExactTokensForTokens(
            amountBorrowed,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit Step1();
        emit Step2(amounts[0], amounts[1]);
        // 计算应还
        uint fee = (amountBorrowed * 3) / 997 + 1;
        uint amountToRepay = amountBorrowed + fee;
        emit Step2(amountBorrowed, amountToRepay);
        IERC20(path[1]).transfer(msg.sender, amountToRepay);

        // 盈利转给发起人
        IERC20(path[1]).transfer(sender, IERC20(path[1]).balanceOf(address(this)));
    }


    function __uniswapV2Call(address fromToken, address ToToken, uint256 amount0) external {
        // 用从poolA中收到的token0 换取poolB中的token1

        // 确定交换路径
        // address token0Addr = IUniswapV2Pair(pair).token0();
        // address token1Addr = IUniswapV2Pair(pair).token1();
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = ToToken;

        uint[] memory amounts = routerA.swapExactTokensForTokens(
            amount0,
            0, // 最小输出量
            path,
            address(this),
            block.timestamp
        );
        uint256 token_in = amounts[0] ;
        uint256 token_out = amounts[1] ;


        address[] memory path2 = new address[](2);
        path2[0] = ToToken;
        path2[1] = fromToken;
        uint[] memory amounts2 = routerB.swapExactTokensForTokens(
            token_out,
            0, // 最小输出量
            path,
            address(this),
            block.timestamp
        );
        uint256 flash_token_in = amounts2[0] ;
        uint256 flash_token_out = amounts2[1] ;

        // 获利数量 (未偿还的情况下)
        uint256 desire = flash_token_out - token_in;
        require(desire > 0, "No profit made");


    }
    
}

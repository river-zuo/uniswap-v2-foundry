// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import "src/flashswap/FlashSwapArbitrage.sol";
import "src/flashswap/FlashArb.sol";
import {IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router02} from "src/UniswapV2Interfaces.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "src/WETH9.sol";
import "src/MyTokenForUniswap.sol";

interface ILegacyUniswapV2Router02Deployer {
    function deploy(address factory, address weth) external returns (address);
}

interface ILegacyFactoryDeployer {
    function deploy(address feeToSetter) external returns (address);
}

contract FlashSwapArbitrageTest is Test {
    using SafeERC20 for IERC20;
    
    // FlashSwapArbitrage public arbitrageContract;
    IUniswapV2Factory public uniswapFactory;
    IUniswapV2Router02 public uniswapRouter;
    WETH9 public weth;

    IUniswapV2Factory public uniswapFactory2;
    IUniswapV2Router02 public uniswapRouter2;
    
    address public tokenA;
    address public tokenB;
    
    address deployer = address(1);
    address user = address(2);

    FlashArb public flashArb;
    
    function setUp() public {
        // 设置模拟环境（使用本地节点进行fork测试）
        string memory rpcUrl = "http://127.0.0.1:8545";
        uint256 forkId = vm.createFork(rpcUrl);
        vm.selectFork(forkId);
        
        // 模拟部署Uniswap工厂和路由器
        address factoryDeployer = 0x67d269191c92Caf3cD7723F116c85e6E9bf55933;
        address legacyFactoryDeployer = 0x09635F643e140090A9A8Dcd712eD6285858ceBef;
        address feeToSetter = address(3);
        
        // 部署WETH
        weth = new WETH9();
        
        // 部署Uniswap V2系统
        uniswapFactory = IUniswapV2Factory(ILegacyFactoryDeployer(legacyFactoryDeployer).deploy(feeToSetter));
        uniswapRouter = IUniswapV2Router02(
            ILegacyUniswapV2Router02Deployer(factoryDeployer).deploy(address(uniswapFactory), address(weth))
        );

        // 部署Uniswap V2系统 第二套
        uniswapFactory2 = IUniswapV2Factory(ILegacyFactoryDeployer(legacyFactoryDeployer).deploy(feeToSetter));
        uniswapRouter2 = IUniswapV2Router02(
            ILegacyUniswapV2Router02Deployer(factoryDeployer).deploy(address(uniswapFactory2), address(weth))
        );
        
        // 部署并添加流动性到两个不同的池子
        vm.startPrank(deployer);
        
        // 部署代币A和B
        tokenA = address(new MyTokenForUniswap("TokenA", "TKA", deployer, 1000000 ether));
        tokenB = address(new MyTokenForUniswap("TokenB", "TKB", deployer, 1000000 ether));
        
        // 创建交易对PoolA (1:1)
        createLiquidityPool(uniswapFactory, uniswapRouter, tokenA, tokenB, 30000 ether, 10000 ether);
        
        // 创建价差 - PoolB (1:0.5)  
        createLiquidityPool(uniswapFactory2, uniswapRouter2, tokenA, tokenB, 10000 ether, 20000 ether);
        
        vm.stopPrank();

        // 部署套利合约
        // arbitrageContract = new FlashSwapArbitrage(address(uniswapFactory));

        flashArb = new FlashArb(address(uniswapRouter), address(uniswapRouter2));
        
        // 给用户一些ETH用于测试
        vm.deal(user, 100 ether);

        // console.log("Deployer:", deployer);
        // console.log("User:", user);
        // console.log("Token A:", tokenA);
        // console.log("Token B:", tokenB);
        // console.log("Uniswap Factory:", address(uniswapFactory));
        // console.log("Uniswap Router:", address(uniswapRouter));
        // console.log("Uniswap Factory 2:", address(uniswapFactory2));
        // console.log("Uniswap Router 2:", address(uniswapRouter2));
        // console.log("FlashArb Contract:", address(flashArb));
        // console.log("WETH Address:", address(weth));
    }
    
    // 创建流动性池
    function createLiquidityPool(
        IUniswapV2Factory  uniswapFactoryP,
        IUniswapV2Router02  uniswapRouterP,
        address tokenA,
        address tokenB,
        uint liquidityA,
        uint liquidityB
    ) internal {
        // 使用factory创建交易对
        uniswapFactoryP.createPair(tokenA, tokenB);
        
        // 获取Pair地址
        address pair = uniswapFactoryP.getPair(tokenA, tokenB);
        
        // 转移代币给部署者
        IERC20(tokenA).transfer(deployer, liquidityA);
        IERC20(tokenB).transfer(deployer, liquidityB);
        
        // 授权
        IERC20(tokenA).approve(address(uniswapRouterP), liquidityA);
        IERC20(tokenB).approve(address(uniswapRouterP), liquidityB);
        
        // 添加流动性
        uniswapRouterP.addLiquidity(
            tokenA,
            tokenB,
            liquidityA,
            liquidityB,
            liquidityA,
            liquidityB,
            deployer,
            block.timestamp + 3600
        );
    }
    
    // 测试正常执行套利的情况
    function testExecuteArbitrage() public {
        // 模拟用户执行套利
        vm.startPrank(user);
        // 执行套利
        address benefit = address(flashArb);
        uint256 before_flash_arb = IERC20(tokenB).balanceOf(benefit); 
        flashArb.executeArb(tokenA, tokenB, 50 ether, 0, true);
        // 验证是否获得利润
        uint256 after_flash_arb = IERC20(tokenB).balanceOf(benefit); 
        console.log("Before Flash Arb:", before_flash_arb);
        console.log("After Flash Arb:", after_flash_arb);
        vm.stopPrank();
    }

}

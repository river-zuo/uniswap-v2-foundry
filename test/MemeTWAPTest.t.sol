// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/twap/MemeTWAPOracle.sol";
import "src/create2/BaseERC20Template.sol";
import "src/create2/ERC20FactoryContract.sol";
import {IUniswapV2Router02, IUniswapV2Pair, IUniswapV2Factory} from "src/UniswapV2Interfaces.sol";
import "src/WETH9.sol";

interface ILegacyUniswapV2Router02Deployer {
    function deploy(address factory, address weth) external returns (address);
}

interface ILegacyFactoryDeployer {
    function deploy(address feeToSetter) external returns (address);
}

contract MemeTWAPTest is Test {
    ERC20FactoryContract factory;
    BaseERC20Template baseTokenTemplate;
    IUniswapV2Router02 router;
    MemeTWAPOracle twapOracle;

    address user = address(2);

    receive() payable external {}

    function setUp() public {
        string memory sepolia = "http://127.0.0.1:8545";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);

        // 部署基础合约
        address deployer = 0x09635F643e140090A9A8Dcd712eD6285858ceBef;
        address uniswapFactory = ILegacyFactoryDeployer(deployer).deploy(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        address router02Deployer = 0x67d269191c92Caf3cD7723F116c85e6E9bf55933;

        WETH9 weth = new WETH9();
        address routerV2 = ILegacyUniswapV2Router02Deployer(router02Deployer).deploy(uniswapFactory, address(weth));
        address weth_addr = IUniswapV2Router02(routerV2).WETH();

        baseTokenTemplate = new BaseERC20Template();
        router = IUniswapV2Router02(routerV2);
        factory = new ERC20FactoryContract(address(baseTokenTemplate), address(router));

        twapOracle = new MemeTWAPOracle();
    }

    function testMemeTWAP() public {
        vm.deal(user, 1001 ether);
        vm.deal(address(factory), 1001 ether); 
        vm.deal(address(router), 1001 ether);

        // vm.prank(user);
        address token = factory.deployInscription("TESTA", 1000e18, 100e18, 0.1 ether);

        console.log("Deployed token address: %s", token);

        // 添加初始流动性
        vm.startPrank(user);
        factory.mintInscription{value: 0.1 ether}(token);
        vm.stopPrank();

        // 构造路径
        address weth = router.WETH();
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;
        
        IUniswapV2Pair pair = IUniswapV2Pair(IUniswapV2Factory(factory.uniswapFactory()).getPair(token, weth));

        console.log("pair address: %s", token);

        // 第一次观察
        twapOracle.observePair(address(pair));

        // 第一次购买
        vm.startPrank(user);
        router.swapExactETHForTokens{value: 0.5 ether}(0, path, user, block.timestamp + 3600);
        vm.stopPrank();

        console.log("firset purchase done");

        // 等待 30 分钟
        vm.warp(block.timestamp + 1800); // 30 minutes later
        vm.roll(block.number + 1); // 强制推进区块编号

        // 第二次购买
        vm.startPrank(user);
        router.swapExactETHForTokens{value: 0.5 ether}(0, path, user, block.timestamp + 3600);
        vm.stopPrank();

        // 第二次观察
        twapOracle.observePair(address(pair));

        console.log("second purchase done");

        // 等待 30 分钟
        vm.warp(block.timestamp + 1800 * 2); // another 30 minutes
        vm.roll(block.number + 1);

        // 第三次购买
        vm.startPrank(user);
        router.swapExactETHForTokens{value: 0.5 ether}(0, path, user, block.timestamp + 3600);
        vm.stopPrank();

        // 第三次观察
        // twapOracle.observePair(address(pair));

        console.log("third purchase done");


        vm.warp(block.timestamp + 1800 * 3); // 再过 30 分钟
        vm.roll(block.number + 1);
        // 获取 TWAP
        uint twapTokenPerETH = twapOracle.getTWAP(address(pair), false); // ETH in Token
        console.log("TWAP (Token per ETH): %s", twapTokenPerETH);

        // 可选：获取 ETH in Token
        uint twapETHInToken = twapOracle.getTWAP(address(pair), true); // Token in ETH
        console.log("TWAP (ETH per Token): %s", twapETHInToken);
    }
}

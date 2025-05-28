// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/create2/ERC20FactoryContract.sol";
import "src/create2/BaseERC20Template.sol";
import {IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router02} from "src/UniswapV2Interfaces.sol";
import "src/WETH9.sol";

interface ILegacyUniswapV2Router02Deployer {
    function deploy(address factory, address weth) external returns (address);
}

interface ILegacyFactoryDeployer {
    function deploy(address feeToSetter) external returns (address);
}

contract ERC20FactoryTest is Test {
    ERC20FactoryContract factory;
    BaseERC20Template baseTokenTemplate;
    IUniswapV2Router02 router;

    address user = address(2);

    receive() payable external {}

    function setUp() public {
        string memory sepolia = "http://127.0.0.1:8545";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);


        address deployer = 0x09635F643e140090A9A8Dcd712eD6285858ceBef;
        // 调用 Legacy 部署器部署 UniswapV2Factory
        address uniswapFactor = ILegacyFactoryDeployer(deployer).deploy(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

        address factoryAddr = uniswapFactor;
        address router02Deployer = 0x67d269191c92Caf3cD7723F116c85e6E9bf55933; // LegacyUniswapV2Router02Deployer address
        WETH9 weth9 = new WETH9();
        // vm.deal(address(weth9), 1001 ether); 
        address routerV2 = ILegacyUniswapV2Router02Deployer(router02Deployer).deploy(factoryAddr, address(weth9));
        address weth_addr = IUniswapV2Router02(routerV2).WETH();

        // vm.deal(address(this), 1 ether);
        // vm.deal(user, 1 ether);
        // 使用 Mock 或真实部署
        baseTokenTemplate = new BaseERC20Template();
        router = IUniswapV2Router02(routerV2); // Uniswap V2 Router 地址
        factory = new ERC20FactoryContract(address(baseTokenTemplate), address(router));

    }

    function testDeployAndAddLiquidity() public {
        vm.deal(user, 1001 ether);
        vm.deal(address(factory), 1001 ether); 
        vm.deal(address(router), 1001 ether);

        vm.prank(user);
        address token = factory.deployInscription("TEST", 1000e18, 100e18, 0.1 ether);

        vm.expectRevert();
        factory.mintInscription{value: 0.09 ether}(token); // 少于 mint price

        vm.prank(user);
        factory.mintInscription{value: 0.1 ether}(token); // 第一次铸造，自动添加流动性

        IUniswapV2Pair pair = IUniswapV2Pair(IUniswapV2Factory(factory.uniswapFactory()).getPair(token, factory.WETH()));
        (uint res0, uint res1,) = pair.getReserves();

        assertGt(res0, 0);
        assertGt(res1, 0);
    }

    function testBuyMemeWithBetterPrice() public {
        vm.deal(user, 1001 ether);
        vm.deal(address(factory), 1001 ether); 
        vm.deal(address(router), 1001 ether);

        // vm.startPrank(user);
        address token = factory.deployInscription("TEST", 1000e18, 100e18, 0.1 ether);
        vm.prank(user);
        factory.mintInscription{value: 0.1 ether}(token); // 初始流动性

        // // 构造路径
        // address weth = router.WETH();
        // address[] memory path = new address[](2);
        // path[0] = weth;
        // path[1] = token;

        // // 查询可兑换数量
        // uint[] memory amounts = router.getAmountsOut(0.5 ether, path);
        // uint amountOutMin = amounts[1] * 99 / 100; // 打九折容错

        uint256 before_token = BaseERC20Template(token).balanceOf(user);
        console.log("before: ", BaseERC20Template(token).balanceOf(user));
        vm.deal(user, 1 ether);
        vm.prank(user);
        // factory.buyMeme{value: 0.5 ether}(token, 100e18, block.timestamp + 3600);
        factory.buyMeme{value: 0.5 ether}(token, 80e18, block.timestamp + 3600);
        console.log("after: ", BaseERC20Template(token).balanceOf(user));
        // assertEq(BaseERC20Template(token).balanceOf(user), 80e18);
        // assertEq(BaseERC20Template(token).balanceOf(user), 80e18);
        assertTrue(BaseERC20Template(token).balanceOf(user) > before_token);
        // vm.stopPrank();
    }
}
// 183291562238930659983
// 50000000000000000000
// 183291562238930659983
// 100000000000000000000
// 183291562238930659983

// uint[] memory amounts
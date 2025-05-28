// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CloneFactory.sol";
import "./BaseERC20Template.sol";
import {IUniswapV2Router01, IUniswapV2Router02, IUniswapV2Factory} from "src/UniswapV2Interfaces.sol";

contract ERC20FactoryContract is CloneFactory {

    address public immutable _erc20Template;
    uint256 public commission = 50; // 5% (基于 basis points, 即 1000 = 100%, 所以 50 表示 5%)

    IUniswapV2Router02 public immutable uniswapRouter;
    address public immutable uniswapFactory;

    constructor(address erc20TemplateAddr, address routerAddress) {
        _erc20Template = erc20TemplateAddr;
        uniswapRouter = IUniswapV2Router02(routerAddress);
        uniswapFactory = IUniswapV2Router02(routerAddress).factory();
    }

    receive() external payable { }

    // ⽤户调⽤该⽅法创建 ERC20 Token合约，symbol 表示新创建代币的代号（ ERC20 代币名字可以使用固定的），totalSupply 表示总发行量， 
    // perMint 表示单次的创建量， price 表示每个代币铸造时需要的费用（wei 计价）。每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。
    function deployInscription(string memory symbol, uint totalSupply, uint perMint, uint price) public returns (address) {
        require(price > commission, "ERC20MintFactory: price must be greater than commissionFee");
        address clone = createClone(_erc20Template);
        BaseERC20Template(clone)._init(symbol, totalSupply, perMint, price, msg.sender);
        return clone;
    }

    // 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用
    function mintInscription(address tokenAddr) payable public  {
        address sender = msg.sender;
        uint256 money = msg.value;
        address factory_address = address(this);
        require(tokenAddr != factory_address, "Token address invalid");
        uint256 price = BaseERC20Template(tokenAddr).getPrice();
        require(money == price, "Sent value must equal token price");

        uint256 perMint = BaseERC20Template(tokenAddr).getPerMint();
        address payable owner = payable(BaseERC20Template(tokenAddr).getOwner());

        BaseERC20Template(tokenAddr).transfer(sender, perMint);

        uint256 commissionAmount = (money * commission) / 1000;
        uint256 toOwner = money - commissionAmount;

        owner.transfer(toOwner);

        // Check if liquidity already exists
        address pair = IUniswapV2Factory(uniswapFactory).getPair(tokenAddr, WETH());
        if (pair == address(0)) {
            // First time adding liquidity using initial mint price
            BaseERC20Template(tokenAddr).approve(address(uniswapRouter), perMint);
            uniswapRouter.addLiquidityETH{value: money}(
                tokenAddr,
                perMint,
                0,
                0,
                address(this),
                block.timestamp + 3600
            );
        } else {
            // Otherwise just send ETH back and no action on LP
            payable(owner).transfer(money);
        }
    }

    function buyMeme(address tokenAddr, uint256 minTokenAmountOut, uint256 deadline) external payable {
        require(msg.value > 0, "Must send ETH to buy Meme tokens");

        address[] memory path = new address[](2);
        path[0] = WETH();
        path[1] = tokenAddr;

        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            minTokenAmountOut,
            path,
            msg.sender,
            deadline
        );
    }

    function WETH() public view returns (address) {
        return uniswapRouter.WETH();
    }

}

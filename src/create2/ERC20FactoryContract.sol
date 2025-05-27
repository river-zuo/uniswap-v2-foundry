// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CloneFactory.sol";
import "./BaseERC20Template.sol";

contract ERC20FactoryContract is CloneFactory {

    address public immutable _erc20Template;
    uint256 public commission;

    constructor(address erc20TemplateAddr, uint _commission) {
        _erc20Template = erc20TemplateAddr;
        commission = _commission;
    }

    // receive() external payable { }

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
        require(tokenAddr != factory_address, "ERC20MintFactory: tokenAddr must not be factory_address");
        require(money == BaseERC20Template(tokenAddr).getPrice(), "ERC20MintFactory: money must be equal to price");
        uint256 perMint = BaseERC20Template(tokenAddr).getPerMint();
        uint256 price = BaseERC20Template(tokenAddr).getPrice();
        address payable owner = payable(BaseERC20Template(tokenAddr).getOwner());
        BaseERC20Template(tokenAddr).transfer(sender, perMint);
        owner.transfer(money - commission);
    }

}

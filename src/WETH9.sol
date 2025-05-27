// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor() {
        // 初始化合约
        // 这里不需要做任何操作，因为WETH9合约的状态变量已经在声明时初始化了
    }

    // function() public payable {
    //     deposit();
    // }
    // 0.8.0及以上版本不支持fallback函数的这种写法
    // 使用receive函数来接收ETH
    // 以及fallback函数来处理其他调用
    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    // function withdraw(uint wad) public {
    //     require(balanceOf[msg.sender] >= wad);
    //     balanceOf[msg.sender] -= wad;
    //     msg.sender.transfer(wad);
    //     Withdrawal(msg.sender, wad);
    // }

    function withdraw(uint256 wad) external {
        require(balanceOf[msg.sender] >= wad, "Insufficient WETH balance");

        balanceOf[msg.sender] -= wad;
        (bool success, ) = msg.sender.call{value: wad}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(msg.sender, wad);
    }

    // function totalSupply() public view returns (uint) {
    //     return this.balance;
    // }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

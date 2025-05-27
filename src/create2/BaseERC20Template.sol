// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20Template {
    string public name;
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // constructor()  {
    //     // set name,symbol,decimals,totalSupply
    //     name = "BaseERC20";
    //     symbol = "BERC20";
    //     decimals = 18;
    //     totalSupply = 1e8 * 1e18;
    //     balances[msg.sender] = totalSupply;  
    // }
    
    uint public perMint; 
    uint public price;
    address public owner;
    bool has_init = false;

    function _init(string memory _symbol, uint _totalSupply, uint _perMint, uint _price, address _owner) external {
        if (has_init) revert("cant't init again");
        // set name,symbol,decimals,totalSupply
        name = _symbol;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;

        perMint = _perMint;
        price = _price;
        owner = _owner;

        has_init = true;
    }
    
    function getPerMint() public view returns (uint256) {
        return perMint;
    }
    function getPrice() public view returns (uint256) {
        return price;
    }
    function getOwner() public view returns (address) {
        return owner;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(_to, _value);
        return true;
    }

    function _transfer(address _to, uint256 _value) internal {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        balances[_from] -= _value;
        balances[_to] += _value;
        uint256 curAllow = allowance(_from, msg.sender);
        require(curAllow >= _value, "ERC20: transfer amount exceeds allowance");
        allowances[_from][msg.sender] = curAllow - _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        return allowances[_owner][_spender];
    }
}
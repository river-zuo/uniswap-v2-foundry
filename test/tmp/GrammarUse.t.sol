// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SimpleLeverageDEXTest is Test { 

    function setUp() public {
        
    }

    function _testAddress() public {
        address a = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        address b = 0x0044cdddB6a900FA2b585Dd299e03d12Fa4293ba;
        console.log("a: ", a);
        console.log("b: ", b);
        bool t = a > b;
        console.log("a > b: ", t);
        bytes memory mem_ab = abi.encodePacked(a, b);
        // console.log("%s", mem_ab);
        console.logBytes(mem_ab);
        // 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc0044cdddb6a900fa2b585dd299e03d12fa4293ba
        keccak256(mem_ab);
        
    }

    function testEncodeTest() public {
        // 拼接两个值
        bytes memory c1 = abi.encode("abc", uint256(123));
        // -> 0x 00000020 ... offset 和 padding 很长
        // 0x0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000000036162630000000000000000000000000000000000000000000000000000000000
        bytes memory c2 = abi.encodePacked("abc", uint256(123));
        // -> 0x 616263 000000000000000000000000000000000000000000000000000000000000007b
        // 0x616263000000000000000000000000000000000000000000000000000000000000007b

        console.logBytes(c1);
        console.logBytes(c2);

        bytes32 c256 = keccak256(c1);
        
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Create2EVM} from "../src/Create2EVM.sol";

contract Create2Test is Test {
    Create2EVM internal create2;
    Counter internal counter;

    function setUp() public {
        create2 = new Create2EVM();
        counter = new Counter();
    }
    function testDeterministicDeploy() public {
        vm.deal(address(0x1), 100 ether);

        vm.startPrank(address(0x1));  
        bytes32 salt = "12345";
        bytes memory creationCode = abi.encodePacked(type(Counter).creationCode);
        
        address computedAddress = create2.computeAddress(salt, keccak256(creationCode));
        address deployedAddress = create2.deploy(salt);
        vm.stopPrank();

        console.log("Computed contract address:", computedAddress);
        console.log("Deployed contract address:", deployedAddress);
    
        assertEq(computedAddress, deployedAddress);  
    }
}

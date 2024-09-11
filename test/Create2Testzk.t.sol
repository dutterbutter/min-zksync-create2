// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Create2ZK} from "../src/Create2zk.sol";

contract Create2Test is Test {
    Create2ZK internal create22;
    Counter internal counter;

    function setUp() public {
        create22 = new Create2ZK();
        counter = new Counter();
    }
    function testDeterministicDeploy() public {
        vm.deal(address(65536), 100 ether);
    
        vm.startPrank(address(65536));  
        bytes32 salt = keccak256(abi.encodePacked("12345")); // zkSync recommends hashing salt values
        bytes memory creationCode = abi.encodePacked(type(Counter).creationCode);
        bytes32 bytecodeHash = keccak256(creationCode);  // Hash the bytecode
        
        // Precompute address using zkSync's derivation method
        address computedAddress = create22.computeCreate2Address(
            address(65536), 
            salt, 
            bytecodeHash, 
            keccak256(abi.encodePacked("")) // Empty constructor arguments for this example
        );
        
        console.log("Computed contract address:", computedAddress);
        
        // Deploy contract on zkSync using zkSync's ContractDeployer system contract
        address deployedAddress;
        bool success;
        bytes memory deployData = abi.encodeWithSignature(
            "create2(bytes32,bytes)", salt, creationCode
        );
        
        // Use zkSync's ContractDeployer system contract for deployment
        (bool success2, bytes memory returnData) = address(0x0000000000000000000000000000000000008006).call(deployData);
        require(success, "Contract deployment failed");
        
        deployedAddress = abi.decode(returnData, (address));
        
        vm.stopPrank();
    
        console.log("Deployed contract address:", deployedAddress);
        
        // Ensure the computed address matches the deployed address
        assertEq(computedAddress, deployedAddress);  
    }    
}

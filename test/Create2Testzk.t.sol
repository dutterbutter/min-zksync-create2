// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ZKCreate2} from "../src/Create2zk.sol";
import {Utils} from "era-contracts/system-contracts/contracts/libraries/Utils.sol";
import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";

contract Create2TestForZKsync is Test {
    ZKCreate2 internal zkcreate2;
    Counter internal counter;

    function setUp() public {
        zkcreate2 = new ZKCreate2();
        counter = new Counter();
    }
    
    function testDeterministicDeploy() public {
        vm.deal(address(65536), 100 ether);
        vm.startPrank(address(65536));

        bytes32 salt = keccak256(abi.encodePacked("12345")); 
        string memory testAaArtifact = vm.readFile(
            "zkout/Counter.sol/Counter.json"
        );
        bytes32 bytecodeHash = vm.parseJsonBytes32(testAaArtifact, ".hash");
        // this is also works and provides the same bytecodehash as above
        //bytes32 bytecodeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getRawCodeHash(address(counter));

        // Precompute address using zkSync's derivation method
        address computedAddress = zkcreate2.computeCreate2Address(
            address(65536), 
            salt, 
            bytecodeHash, 
            keccak256("")
        );
        console.log("Computed contract address:", computedAddress);
        
        // Deploy contract on zkSync using zkSync's ContractDeployer system contract
        address deployedAddress = zkcreate2.deployCreate2(
            salt, 
            bytecodeHash, 
            abi.encode("")
        );
        console.log("Deployed contract address:", deployedAddress);

        vm.stopPrank();
        // Ensure the computed address matches the deployed address
        assertEq(computedAddress, deployedAddress);  
    }    
}

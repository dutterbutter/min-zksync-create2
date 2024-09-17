// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Create2ZK} from "../src/Create2ZK.sol";
import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";

contract Create2DeterministicDeployTest is Test {
    Create2ZK internal create2ZK;
    Counter internal counter;

    function setUp() public {
        create2ZK = new Create2ZK();
        counter = new Counter();
    }

    function testDeterministicDeployment() public {
        address deployerAddress = address(create2ZK);
        
        vm.deal(deployerAddress, 100 ether);
        vm.startPrank(deployerAddress);

        bytes32 salt = "12345";
        // Retrieve the bytecode hash of the Counter contract from the ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT
        bytes32 bytecodeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getRawCodeHash(address(counter));

        address expectedAddress = create2ZK.computeCreate2Address(
            deployerAddress,
            salt,
            bytecodeHash,
            keccak256(abi.encode())
        );

        address deployUsingSystemContractDeployer = create2ZK.deploy(
            salt,
            bytecodeHash,
            abi.encode()
        );
       
        console.log("Address computed:", expectedAddress);
        console.log("Address deployed:", deployUsingSystemContractDeployer);

        vm.stopPrank();

        assertEq(deployUsingSystemContractDeployer, expectedAddress);
    }
}

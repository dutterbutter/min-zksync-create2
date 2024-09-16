// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ZKCreate2} from "../src/Create2zk.sol";
import {Utils} from "era-contracts/system-contracts/contracts/libraries/Utils.sol";
import {L2ContractHelper} from "era-contracts/l2-contracts/contracts/L2ContractHelper.sol";
import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";

contract Create2DeterministicDeployTest is Test {
    ZKCreate2 internal zkCreate2;
    Counter internal counter;

    function setUp() public {
        zkCreate2 = new ZKCreate2();
        counter = new Counter();
    }

    function getBytecodeHash(string memory path) internal view returns (bytes32) {
        string memory artifact = vm.readFile(path);
        return vm.parseJsonBytes32(artifact, ".hash");
    }

    function testDeterministicDeployment() public {
        address deployerAddress = address(zkCreate2);
        vm.deal(deployerAddress, 100 ether);
        vm.startPrank(deployerAddress);

        
        bytes32 salt = "12345";
        bytes32 bytecodeHash = getBytecodeHash("zkout/Counter.sol/Counter.json");

        address expectedAddress = L2ContractHelper.computeCreate2Address(
            deployerAddress,
            salt,
            bytecodeHash,
            keccak256(abi.encode())
        );

        // Deploy using system contract deployer
        //
        // address deployUsingSystemContractDeployer = zkCreate2.deployCreate2(
        //     salt,
        //     bytecodeHash,
        //     abi.encode()
        // );
        address deployedAddressByZKCreate2 = zkCreate2.deploy(salt);
       
        console.log("Address computed using L2ContractHelper:", expectedAddress);
        console.log("Address deployed using zkCreate2.deploy:", deployedAddressByZKCreate2);

        vm.stopPrank();

        assertEq(deployedAddressByZKCreate2, expectedAddress);
    }
}

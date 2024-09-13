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
        vm.deal(address(65536), 100 ether);
        vm.startPrank(address(65536));

        bytes32 salt = "12345";
        bytes32 bytecodeHash = getBytecodeHash("zkout/Counter.sol/Counter.json");

        address expectedAddress = L2ContractHelper.computeCreate2Address(
            address(65536),
            salt,
            bytecodeHash,
            keccak256(abi.encode())
        );

        console.log("Deployer address:", address(65536));
        console.log("Transaction origin:", tx.origin);

        // Cannot deploy both with SystemContractDeployer and zkCreate2.deploy in the same test
        // Results in a revert - FAIL. Reason: revert: Code hash is non-zero
        //
        // address deployUsingSystemContractDeployer = zkCreate2.deployCreate2(
        //     salt,
        //     bytecodeHash,
        //     abi.encode()
        // );
        address deployedAddressByZKCreate2 = zkCreate2.deploy(salt);
        address deployedAddressDirectly = address(new Counter{salt: salt}());

        console.log("Address computed using L2ContractHelper:", expectedAddress);
        console.log("Address deployed using zkCreate2.deploy:", deployedAddressByZKCreate2);
        console.log("Address deployed directly using new Counter:", deployedAddressDirectly);
        //console.log("Address deployed using SystemContractsCaller:", deployUsingSystemContractDeployer);

        vm.stopPrank();

        // Passes
        assertEq(deployedAddressDirectly, expectedAddress);

        // Fails- [FAIL. Reason: assertion failed: 0xC168dfc04a7627e4c85B6d7B391C0561A27a7EC4 != 0x7639317afbb07519a1bcFB558d1F49f9f3130899] testDeterministicDeployment() (gas: 60672)
        assertEq(deployedAddressByZKCreate2, expectedAddress);
    }
}

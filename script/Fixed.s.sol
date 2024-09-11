// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract FixedContractFactoryScript is Script {
    function run() external {
        vm.startBroadcast();

        // Correct code: using type(MyContract).creationCode so zkSync can handle the deployment
        bytes32 salt = keccak256(abi.encodePacked("some_salt"));
        bytes memory bytecode = type(Counter).creationCode;

        address addr;
        assembly {
            // This works correctly on zkSync since the bytecode is known at compile-time
            addr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        console.log("Deployed contract address:", addr);

        vm.stopBroadcast();
    }
}

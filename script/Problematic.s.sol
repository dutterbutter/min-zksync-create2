// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract ProblematicContractFactoryScript is Script {
    function run() external {
        vm.startBroadcast();

        // Problematic code: dynamically passing bytecode to CREATE2
        bytes32 salt = keccak256(abi.encodePacked("some_salt"));
        bytes memory bytecode = abi.encodePacked(
            hex"6080604052348015600f57600080fd5b506040516101e03803806101e083398181016040526020811015600257600080fd5b505160005560c0806100326000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c806360fe47b114602d575b600080fd5b60336035565b005b60005481565b60005556fea26469706673582212204c20c59f2369d78f9bcb0c6b192d5ef93d0e53fc3ba2be1b27ab108f0140d23f64736f6c634300080d0033",
            abi.encode(1234) // Arguments passed for the constructor (e.g., a uint256 value)
        );

        address addr;
        assembly {
            // This will fail on zkSync because the compiler isn't aware of the bytecode
            addr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        console.log("Deployed contract address:", addr);

        vm.stopBroadcast();
    }
}

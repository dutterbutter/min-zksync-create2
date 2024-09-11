// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";

contract Create2 {

    error Create2EmptyBytecode();

    error Create2FailedDeployment();

    function deploy(bytes32 salt, bytes memory creationCode) external payable returns (address addr) {
        if (creationCode.length == 0) {
            console.log("Empty bytecode!!");
            revert Create2EmptyBytecode();
        }
        
        assembly {
            addr := create2(callvalue(), add(creationCode, 0x20), mload(creationCode), salt)
        }
        if (addr == address(0)) {
            console.log("Failed deployment!!");
            revert Create2FailedDeployment();
        }
    }
    function computeAddress(bytes32 salt, bytes32 creationCodeHash) external view returns (address addr) {
        address contractAddress = address(this);
        
        assembly {
            let ptr := mload(0x40)
    
            mstore(add(ptr, 0x40), creationCodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, contractAddress)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}

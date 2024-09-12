// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";
import {Counter} from "./Counter.sol";

contract Create2 {

    error Create2EmptyBytecode();

    error Create2FailedDeployment();

    function deploy(bytes32 salt) external payable returns (address addr) {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        Counter counter = new Counter{salt: salt}();
        if (address(counter) == address(0)) {
            revert Create2FailedDeployment();
        }
        return address(counter);
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

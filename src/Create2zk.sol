// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";
import {SystemContractsCaller} from "era-contracts/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {DEPLOYER_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";
import {Counter} from "./Counter.sol";
import {L2ContractHelper} from "era-contracts/l2-contracts/contracts/L2ContractHelper.sol";

contract ZKCreate2 {
    
    error Create2FailedDeployment();

    function deployCreate2(
        bytes32 salt, 
        bytes32 bytecodeHash, 
        bytes calldata inputData
    ) external payable returns (address create2Address) {
        
        console.log("\n---------- Deployment Parameters ----------");
        console.log("Salt:");
        console.logBytes32(salt);
        console.log("Bytecode Hash:");
        console.logBytes32(bytecodeHash);
        console.log("Constructor Input Data:");
        console.logBytes(inputData);
        console.log("Gas Limit Available:", gasleft());
        console.log("Deployer System Contract Address:");
        console.logAddress(address(DEPLOYER_SYSTEM_CONTRACT));
        console.log("---------- Starting CREATE2 Deployment ----------\n");

        (bool success, bytes memory returnData) = SystemContractsCaller
            .systemCallWithReturndata(
                uint32(gasleft()),
                address(DEPLOYER_SYSTEM_CONTRACT),
                uint128(0),
                abi.encodeCall(
                    DEPLOYER_SYSTEM_CONTRACT.create2,
                    (
                        salt,
                        bytecodeHash,
                        inputData
                    )
                )
            );
        
        if (!success) {
            revert Create2FailedDeployment();
        }
        
        create2Address = abi.decode(returnData, (address));
        console.log("Contract deployed at:", create2Address);
    }

    function computeCreate2Address(
        address sender,
        bytes32 salt,  
        bytes32 bytecodeHash,
        bytes32 constructorInputHash
    ) external pure returns (address) {
        return L2ContractHelper.computeCreate2Address(
            sender,
            salt,
            bytecodeHash,
            constructorInputHash
        );
    }

    function deploy(bytes32 salt) external payable returns (address addr) {
        console.log("Transaction Origin (tx.origin):", tx.origin);
        console.log("Message Sender (msg.sender):", msg.sender);
        addr = address(new Counter{salt: salt}());
        console.log("Contract deployed at (via native CREATE2):", addr);
    }
}

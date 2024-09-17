// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";
import {SystemContractsCaller} from "era-contracts/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {DEPLOYER_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";
import {Counter} from "./Counter.sol";
import {L2ContractHelper} from "era-contracts/l2-contracts/contracts/L2ContractHelper.sol";

// This contract is used to deploy a contract using create2 on ZKsync based chains
contract Create2ZK {
    
    error Create2FailedDeployment();

    function deploy(
        bytes32 salt, 
        bytes32 bytecodeHash, 
        bytes calldata inputData
    ) external payable returns (address create2Address) {
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
}

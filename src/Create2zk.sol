// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";
import {SystemContractsCaller} from "era-contracts/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {DEPLOYER_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";
import {Counter} from "./Counter.sol";

contract ZKCreate2 {
    
    error Create2FailedDeployment();

    function deployCreate2(bytes32 salt, bytes32 bytecodeHash, bytes calldata inputData) external payable returns (address create2Address) {
        
        console.log("");
        console.log("---------- Parameters ----------");
        console.log("--- salt ---");   
        console.logBytes32(salt);
        console.log("--- bytecodehash ---"); 
        console.logBytes32(bytecodeHash);
        console.log("--- input data ---");
        console.logBytes(inputData);
        console.log("Gas Limit: ", gasleft());
        console.log("DEPLOYER_SYSTEM_CONTRACT: ");
        console.logAddress(address(DEPLOYER_SYSTEM_CONTRACT));
        console.log("---------- Deploying create2 contract ----------");
        console.log("");

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
            require(success, "Deployment failed!");
    
            (create2Address) = abi.decode(returnData, (address));
    }
    // Taken from era-contracts/l2-contracts/contracts/L2ContractHelper.sol
    function computeCreate2Address(
        address _sender,
        bytes32 _salt,  
        bytes32 _bytecodeHash,
        bytes32 _constructorInputHash
    ) external pure returns (address) {
        bytes32 senderBytes = bytes32(uint256(uint160(_sender)));
        bytes32 data = keccak256(
            bytes.concat(keccak256("zksyncCreate2"), senderBytes, _salt, _bytecodeHash, _constructorInputHash)
        );

        return address(uint160(uint256(data)));
    }
    // This does not work on ZKsync?
    // Well it deploys but does not match the address
    // assuming due to the differences in address derivation
    function deploy(bytes32 salt) external payable returns (address addr) {
        Counter counter = new Counter{salt: salt}();
        if (address(counter) == address(0)) {
            revert Create2FailedDeployment();
        }
        return address(counter);
    }
}

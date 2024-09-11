// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/Console.sol";

contract Create2ZK {
    error Create2EmptyBytecode();
    error Create2FailedDeployment();

    // zkSync uses a system contract for deploying contracts
    address constant CONTRACT_DEPLOYER = address(0x0000000000000000000000000000000000008006);

    function deploy(bytes32 salt, bytes memory creationCode) external payable returns (address addr) {
        
            // (bool success, bytes memory returnData) = SystemContractsCaller
            //     .systemCallWithReturndata(
            //         uint32(gasleft()),
            //         address(DEPLOYER_SYSTEM_CONTRACT),
            //         uint128(0),
            //         abi.encodeCall(
            //             DEPLOYER_SYSTEM_CONTRACT.create2,
            //             (
            //                 salt,
            //                 aaBytecodeHash,
            //                 input,
            //                 IContractDeployer.AccountAbstractionVersion.Version1
            //             )
            //         )
            //     );
            // require(success, "Deployment failed");
    
            // (accountAddress) = abi.decode(returnData, (address));
    }

  /// @notice Computes the create2 address for a Layer 2 contract.
    /// @param _sender The address of the sender.
    /// @param _salt The salt value to use in the create2 address computation.
    /// @param _bytecodeHash The contract bytecode hash.
    /// @param _constructorInputHash The hash of the constructor input data.
    /// @return The create2 address of the contract.
    /// NOTE: L2 create2 derivation is different from L1 derivation!
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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Create2ZK} from "../src/Create2ZKWithSystemDeployer.sol";
import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/contracts/Constants.sol";
import {L2ContractHelper} from "era-contracts/l2-contracts/contracts/L2ContractHelper.sol";
import {Create2Factory} from "era-contracts/system-contracts/contracts/Create2Factory.sol";

contract Create2DeterministicDeployTest is Test {
    // Contract instances
    Create2ZK private create2ZK;
    Counter private counter;

    /// @dev Retrieves the bytecode hash from a given artifact path.
    function getBytecodeHash(
        string memory path
    ) internal view returns (bytes32 bytecodeHash) {
        string memory artifact = vm.readFile(path);
        bytecodeHash = vm.parseJsonBytes32(artifact, ".hash");
    }

    /// @dev Sets up the initial state for the tests.
    function setUp() public {
        create2ZK = new Create2ZK();
        counter = new Counter();
    }

    /// @notice Tests deterministic deployment using the System Contract deployer.
    function testSystemContractDeployment() public {
        address deployer = address(create2ZK);

        // Fund the deployer contract
        vm.deal(deployer, 100 ether);
        vm.startPrank(deployer);

        bytes32 salt = "12345";
        bytes32 bytecodeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT
            .getRawCodeHash(address(counter));

        // Compute the expected address
        address expectedAddress = L2ContractHelper.computeCreate2Address(
            deployer,
            salt,
            bytecodeHash,
            keccak256(abi.encode())
        );

        // Deploy the contract
        address deployedAddress = create2ZK.deploy(
            salt,
            bytecodeHash,
            abi.encode()
        );

        // Assert that the computed and actual addresses match
        assertEq(
            deployedAddress,
            expectedAddress,
            "System contract deployment address mismatch"
        );

        vm.stopPrank();
    }

    /// @notice Tests deterministic deployment using the Create2Factory.
    function testCreate2FactoryDeployment() public {
        bytes32 salt = "12345";
        bytes32 bytecodeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT
            .getRawCodeHash(address(counter));

        // Deploy using Create2Factory
        Create2Factory create2Factory = new Create2Factory();
        address deployedAddress = create2Factory.create2(
            salt,
            bytecodeHash,
            abi.encode()
        );

        // Compute the expected address
        address expectedAddress = L2ContractHelper.computeCreate2Address(
            address(create2Factory),
            salt,
            bytecodeHash,
            keccak256(abi.encode())
        );

        // Assert that the computed and actual addresses match
        assertEq(
            deployedAddress,
            expectedAddress,
            "Create2Factory deployment address mismatch"
        );
    }

    /// @notice Tests deterministic deployment using the `create2` syntax directly.
    function testCreate2SyntaxDeployment() public {
        bytes32 bytecodeHash = getBytecodeHash(
            "zkout/Counter.sol/Counter.json"
        );
        address deployer = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
        bytes32 salt = "12345";
        bytes32 constructorInputHash = keccak256(abi.encode());

        // Compute the expected address
        address expectedAddress = L2ContractHelper.computeCreate2Address(
            deployer,
            salt,
            bytecodeHash,
            constructorInputHash
        );

        // Deploy using the create2 syntax
        address deployedAddress = address(new Counter{salt: salt}());

        // Assert that the computed and actual addresses match
        assertEq(
            deployedAddress,
            expectedAddress,
            "Direct create2 deployment address mismatch"
        );
    }
}

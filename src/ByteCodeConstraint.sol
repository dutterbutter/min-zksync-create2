pragma solidity ^0.8.0;

contract ContractFactory {
    function deploy(bytes32 salt, bytes memory bytecode) public returns (address) {
        address addr;
        assembly {
            // Fails on zkSync: compiler is unaware of bytecode
            addr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        return addr;
    }
}

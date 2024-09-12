# min-zksync-create2

This repository demonstrates how to compute and deploy contracts using `create2` on ZKsync and compares it to traditional EVM-based chains. It provides tests for deploying smart contracts using `create2` on both ZKsync and EVM, allowing you to observe the differences between the two implementations.

## Prerequisites

Ensure that you have `foundry-zksync` installed. Follow the installation instructions in the [Foundry-zksync repository](https://github.com/matter-labs/foundry-zksync?tab=readme-ov-file#quick-install).

## Getting Started

To get started with this repository, follow the steps below:

### 1. Clone the repository

```bash
git clone git@github.com:dutterbutter/min-zksync-create2.git
```

Navigate into the project directory:

```bash
cd min-zksync-create2
```

### 2. Install Dependencies

Install the necessary dependencies using `forge`:

```bash
forge install
```

### 3. Build the Project for zkSync

To build the project for zkSync, run:

```bash
forge build --zksync
```

You may encounter a compilation error due to a placeholder value in the system contracts library.

### 4. Fix the Compilation Error

To fix the compilation error, navigate to the `Constants.sol` file in the `era-contracts` library and replace the placeholder value with the actual system contract offset value:

- File: `lib/era-contracts/system-contracts/contracts/Constants.sol:20:44`
  
- Change:

```solidity
uint160 constant SYSTEM_CONTRACTS_OFFSET = {{SYSTEM_CONTRACTS_OFFSET}}; // 2^15
```

- To:

```solidity
uint160 constant SYSTEM_CONTRACTS_OFFSET = 32768; // 2^15
```

### 5. Run Tests

After fixing the compilation error, you can run the tests for both zkSync and EVM-based chains to observe the differences.

#### Running Tests on zkSync

To run the tests on zkSync, use the following command:

```bash
forge test --match-path test/Create2Testzk.t.sol -vvv --zksync --zk-enable-eravm-extensions
```

#### Running Tests on EVM

To run the tests on an EVM-based chain, use the following command:

```bash
forge test --match-path test/Create2Test.t.sol -vvv
```
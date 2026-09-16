# BondokWeb3 (BW3)

A fully tested **ERC-20 token smart contract** built with **Solidity `^0.8.31`**, **OpenZeppelin Contracts**, and **Foundry**.

The project implements a mintable ERC-20 token with owner-controlled minting and a comprehensive Foundry test suite covering token behavior, access control, transfers, approvals, allowances, and ownership management.

## Token Details

| Property | Value |
|---|---|
| Name | `BondokWeb3` |
| Symbol | `BW3` |
| Decimals | `18` |
| Initial Supply | `0` |
| Minting | Owner-only |

## Tech Stack

- **Solidity** `^0.8.31`
- **OpenZeppelin Contracts**
- **Foundry / Forge**
- **Ethereum / EVM**
- **Git & GitHub**

## Smart Contract

`BondokWeb3` inherits from OpenZeppelin's `ERC20` and `Ownable` contracts.

### Core Function

```solidity
function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
}
```

Only the current contract owner can mint new tokens.

The constructor initializes:

```text
Name:    BondokWeb3
Symbol:  BW3
Owner:   msg.sender
Supply:  0
```

## ERC-20 Functionality

The contract provides the standard ERC-20 functionality inherited from OpenZeppelin, including:

- `transfer()`
- `approve()`
- `transferFrom()`
- `balanceOf()`
- `allowance()`
- `totalSupply()`
- `decimals()`
- `name()`
- `symbol()`

It also supports ownership management through `Ownable`, including:

- `transferOwnership()`
- `renounceOwnership()`

## Test Coverage

The Foundry test suite covers:

### Constructor
- Token name
- Token symbol
- Initial owner
- Initial total supply
- Token decimals

### Minting
- Owner can mint
- Multiple mints
- Non-owner cannot mint
- Minting to the zero address reverts

### Transfers
- Successful transfers
- Insufficient balance reverts
- Transfer to zero address reverts
- Self-transfer behavior
- `Transfer` event emission

### Approvals & Allowances
- Successful approval
- Allowance overwrite
- Zero-address spender rejection
- `Approval` event emission

### `transferFrom`
- Successful delegated transfer
- Insufficient allowance rejection
- Infinite approval behavior
- Transfer to zero address rejection

### Ownership
- Successful ownership transfer
- Non-owner cannot transfer ownership
- Zero address cannot become owner
- New owner can mint
- Previous owner can no longer mint

### Renouncing Ownership
- Ownership can be renounced
- Non-owner cannot renounce ownership
- After renouncing ownership, minting is no longer available to the previous owner

## Project Structure

```text
ERC20/
├── src/
│   └── BondokWeb3.sol
├── test/
│   └── BondokWeb3.t.sol
├── lib/
├── foundry.toml
├── foundry.lock
├── .gitmodules
├── .gitignore
└── README.md
```

## Getting Started

### Clone

```bash
git clone https://github.com/MohamedBondok-real/ERC20.git
cd ERC20
```

### Install Dependencies

```bash
forge install
```

### Build

```bash
forge build
```

### Run Tests

```bash
forge test
```

For more detailed output:

```bash
forge test -vv
```

## What I Learned

This project helped me strengthen my understanding of:

- ERC-20 token standards
- OpenZeppelin contract inheritance
- Token minting and supply management
- Ownership and access control
- `transfer`, `approve`, and `transferFrom`
- ERC-20 allowances and infinite approvals
- Custom error handling from OpenZeppelin
- Event testing with Foundry
- Revert testing with `vm.expectRevert`
- Caller simulation with `vm.prank`
- Smart-contract unit testing and edge cases

## Author

**Mohamed Bondok**

Computer Science Student at Tanta University  
Aspiring Web3 & Blockchain Developer

**GitHub:**  
https://github.com/MohamedBondok-real

**LinkedIn:**  
https://www.linkedin.com/in/mohamed-bondok-7226793b

---

Built with Solidity & Foundry by Mohamed Bondok.

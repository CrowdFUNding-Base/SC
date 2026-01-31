# 1. Smart Contract Guide

This guide provides comprehensive instructions for developing, testing, and deploying the CrowdFUNding smart contracts.

## Overview

The Smart Contract is the backbone of the CrowdFUNding platform. It is a **Singleton Contract**, meaning there is only one instance of the contract that manages all crowdfunding campaigns. This design choice ensures that all campaign data is stored in a single location, making it easier to manage and query.

The smart contracts are built using:

- **Solidity** ^0.8.30 for contract logic
- **Foundry** for development, testing, and deployment
- **OpenZeppelin** for battle-tested security libraries

## Prerequisites

Ensure you have **Foundry** installed on your system:

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
```

Expected output: `forge 0.2.0 (...)` or similar.

## Project Structure

The smart contracts follow a standard Foundry project structure:

```
├── src/
│   ├── Campaign.sol          # Core crowdfunding contract
│   ├── Badge.sol             # Achievement NFT contract
│   ├── MockSwap.sol          # Token exchange router
│   └── MockToken/
│       ├── MockIDRX.sol      # IDRX stablecoin mock
│       └── MockUSDC.sol      # USDC mock
├── script/
│   └── Deploy.s.sol          # Deployment script
├── test/
│   ├── Campaign.t.sol        # Campaign tests
│   ├── Badge.t.sol           # Badge tests
│   └── MockSwap.t.sol        # Swap tests
├── lib/                       # Dependencies (OpenZeppelin)
├── foundry.toml              # Foundry configuration
├── Makefile                  # Build shortcuts
└── .env                      # Environment variables
```

### Contract Descriptions

| Contract         | Responsibility                                                                                                                                                                                        |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Campaign.sol** | The core singleton contract that manages all crowdfunding campaigns. It handles campaign creation, multi-currency donations with automatic IDRX conversion, and fund withdrawals for campaign owners. |
| **Badge.sol**    | An ERC721 NFT contract that mints achievement badges for donors. Each badge contains metadata about the donor's contribution milestones and can be displayed as proof of impact.                      |
| **MockSwap.sol** | A token exchange router that converts BASE (ETH) and USDC donations into IDRX. It maintains exchange rates and executes atomic swaps during the donation process.                                     |
| **MockIDRX.sol** | A mock ERC20 token representing IDRX (Indonesian Rupiah stablecoin) with 2 decimal places. Used as the unified settlement currency for all campaigns.                                                 |
| **MockUSDC.sol** | A mock ERC20 token representing USDC with 6 decimal places. Allows testing of multi-currency donation flows.                                                                                          |

## Environment Setup

Create a `.env` file in the project root with the following configuration:

```env
# ============================
# RPC URLs
# ============================

# Base Sepolia Testnet
BASE_RPC_URL=https://sepolia.base.org

# For better performance, use Alchemy or Infura:
# BASE_RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR_API_KEY

# ============================
# Private Keys
# ============================

# Local Anvil development (default Account #0)
# ONLY for local testing - never use on mainnet!
LOCAL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Testnet/Mainnet deployment (your actual wallet)
# NEVER commit this file!
PRIVATE_KEY=your_private_key_here

# ============================
# Contract Verification
# ============================

# Basescan API Key
ETHERSCAN_API_KEY=your_basescan_api_key
```

### How to Get Environment Keys

The following table provides instructions for obtaining each required key:

| Variable            | How to Obtain                                                                           |
| ------------------- | --------------------------------------------------------------------------------------- |
| `BASE_RPC_URL`      | [Alchemy](https://alchemy.com) or [Infura](https://infura.io) → Create Base Sepolia app |
| `ETHERSCAN_API_KEY` | [Basescan](https://basescan.org) → My Account → API Keys                                |
| `PRIVATE_KEY`       | MetaMask → Account Details → Export Private Key                                         |

> **Security Warning**:
>
> - Never commit `.env` to git
> - Never share private keys
> - Add `.env` to `.gitignore`

## Installation

### Step 1: Install Dependencies

```bash
forge install
```

This installs OpenZeppelin and other dependencies.

### Step 2: Build Contracts

```bash
forge build
```

### Step 3: Verify Setup

```bash
forge test
```

All tests should pass.

## Testing

Foundry provides powerful testing capabilities. All tests are written in Solidity.

### Run All Tests

```bash
forge test
```

### Run with Verbose Output

Different verbosity levels show more detail:

```bash
forge test -vvv
```

| Flag    | What it shows                |
| ------- | ---------------------------- |
| `-v`    | Assertion failures           |
| `-vv`   | Test names                   |
| `-vvv`  | Transaction traces           |
| `-vvvv` | Everything including storage |

### Run Specific Test

```bash
# Run tests matching a pattern
forge test --match-test testDonate -vvv

# Run tests in a specific file
forge test --match-path test/Campaign.t.sol
```

### Gas Report

Generate a gas usage report:

```bash
forge test --gas-report
```

### Test Coverage

Check code coverage:

```bash
forge coverage
```

## Deployment

### Option 1: Local Development (Anvil)

For local testing, use Anvil to run a local Ethereum node:

#### Step 1: Start Local Node

Open a new terminal and run:

```bash
anvil
```

This starts a local Ethereum node at `http://127.0.0.1:8545`

#### Step 2: Deploy Locally

```bash
make local-deploy
```

Or manually:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $LOCAL_PRIVATE_KEY \
  --broadcast
```

### Option 2: Base Sepolia Testnet

For testnet deployment, follow these steps:

#### Step 1: Ensure Environment is Set

Verify `.env` has:

- `BASE_RPC_URL`
- `PRIVATE_KEY`
- `ETHERSCAN_API_KEY` (for verification)

#### Step 2: Dry Run (Simulation)

Simulate the deployment without sending transactions:

```bash
make base-dry
```

#### Step 3: Deploy

Execute the actual deployment:

```bash
make base-deploy
```

#### Step 4: Deploy with Verification (Recommended)

Deploy AND verify contracts on Basescan:

```bash
make base-deploy-verify
```

## Makefile Commands

The Makefile provides convenient shortcuts for common operations:

| Command                   | Environment  | Description                 |
| ------------------------- | ------------ | --------------------------- |
| `make local-dry`          | Local        | Simulate deployment locally |
| `make local-deploy`       | Local        | Deploy to Anvil node        |
| `make base-dry`           | Base Sepolia | Simulate on testnet         |
| `make base-deploy`        | Base Sepolia | Deploy to testnet           |
| `make base-deploy-verify` | Base Sepolia | Deploy + verify on Basescan |

## Interacting with Contracts

Use Foundry's `cast` CLI to interact with deployed contracts.

### Read Campaign Info

Query campaign data from the blockchain:

```bash
cast call $CAMPAIGN_ADDRESS "getCampaignInfo(uint256)" 1 \
  --rpc-url $BASE_RPC_URL
```

### Create Campaign

Create a new crowdfunding campaign:

```bash
cast send $CAMPAIGN_ADDRESS \
  "createCampaign(string,string,uint256)" \
  "My Campaign" "Creator Name" 100000000 \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Donate with BASE (Native Token)

Make a donation using native ETH/BASE:

```bash
cast send $CAMPAIGN_ADDRESS \
  "donate(uint256)" 1 \
  --value 0.01ether \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Donate with ERC20

Make a donation using an ERC20 token (requires approval first):

```bash
# First approve the Campaign contract
cast send $IDRX_ADDRESS \
  "approve(address,uint256)" $CAMPAIGN_ADDRESS 100000 \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY

# Then donate
cast send $CAMPAIGN_ADDRESS \
  "donate(uint256,uint256,address)" 1 100000 $IDRX_ADDRESS \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Withdraw Funds

Campaign owners can withdraw accumulated funds:

```bash
cast send $CAMPAIGN_ADDRESS \
  "withdraw(uint256,uint256)" 1 50000 \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

## Minting Mock Tokens

For testing, you can mint mock tokens to your wallet:

### Mint Mock IDRX

```bash
# Mint 1000 IDRX (2 decimals, so 100000 = 1000.00 IDRX)
cast send $MOCK_IDRX_ADDRESS \
  "mint(address,uint256)" $YOUR_WALLET 100000 \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Mint Mock USDC

```bash
# Mint 1000 USDC (6 decimals, so 1000000000 = 1000.000000 USDC)
cast send $MOCK_USDC_ADDRESS \
  "mint(address,uint256)" $YOUR_WALLET 1000000000 \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY
```

## Deployed Contract Addresses

The following contracts are deployed and verified on Base Sepolia:

| Contract      | Address                                                                                                                       |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Mock IDRX** | [0x387551ac55Bb6949d44715D07880f8c6260934B6](https://sepolia.basescan.org/address/0x387551ac55Bb6949d44715D07880f8c6260934B6) |
| **Mock USDC** | [0x1b929eB40670aA4e0D757d45cA9aea2311a25a97](https://sepolia.basescan.org/address/0x1b929eB40670aA4e0D757d45cA9aea2311a25a97) |
| **MockSwap**  | [0x554366984fD2f5D82c753F91357d80c29F887F17](https://sepolia.basescan.org/address/0x554366984fD2f5D82c753F91357d80c29F887F17) |
| **Campaign**  | [0x44e87aa98d721Dbcf368690bF5aAb1F3dD944dA9](https://sepolia.basescan.org/address/0x44e87aa98d721Dbcf368690bF5aAb1F3dD944dA9) |
| **Badge**     | [0xaE32Df9Fb677aE68C5A1F956761a42e269Ebdc99](https://sepolia.basescan.org/address/0xaE32Df9Fb677aE68C5A1F956761a42e269Ebdc99) |

## Contract Functions Reference

### Campaign.sol

The following table summarizes all public functions in the Campaign contract:

| Function                          | Parameters                            | Description                     |
| --------------------------------- | ------------------------------------- | ------------------------------- |
| `createCampaign`                  | `name`, `creatorName`, `targetAmount` | Create new campaign             |
| `donate(uint256)`                 | `campaignId` + `msg.value`            | Donate BASE (auto-swap to IDRX) |
| `donate(uint256,uint256,address)` | `campaignId`, `amount`, `tokenIn`     | Donate ERC20                    |
| `withdraw(uint256,uint256)`       | `campaignId`, `amount`                | Withdraw IDRX                   |
| `getCampaignInfo`                 | `campaignId`                          | Get campaign details            |

### Badge.sol

| Function       | Parameters                  | Description          |
| -------------- | --------------------------- | -------------------- |
| `mintBadge`    | `to`, `name`, `description` | Mint achievement NFT |
| `getBadgeInfo` | `tokenId`                   | Get badge metadata   |

### MockSwap.sol

| Function          | Parameters                            | Description        |
| ----------------- | ------------------------------------- | ------------------ |
| `addToken`        | `name`, `address`, `decimals`, `rate` | Register token     |
| `swap`            | `tokenIn`, `tokenOut`, `amountIn`     | Swap ERC20 tokens  |
| `swapETHForToken` | `tokenOut` + `msg.value`              | Swap ETH for ERC20 |
| `getQuote`        | `tokenIn`, `tokenOut`, `amountIn`     | Get swap quote     |

## Troubleshooting

### Compilation Errors

**Error:** `Source file not found`

**Solution:** Run `forge install` to install dependencies.

### Deployment Failed

**Error:** `Transaction reverted`

**Solution:**

1. Check contract constructor parameters
2. Verify sufficient gas
3. Check account balance

### Verification Failed

**Error:** `Unable to verify`

**Solution:**

1. Wait for Basescan to index the contract (few minutes)
2. Verify `ETHERSCAN_API_KEY` is correct
3. Re-run verification manually

### Gas Estimation Failed

**Error:** `Gas required exceeds allowance`

**Solution:**

1. Add more gas: `--gas-limit 3000000`
2. Check for infinite loops
3. Verify input parameters

# 🎮 CrowdFUNding - Gamified Crowdfunding Smart Contracts

<p align="center">
  <img src="https://img.shields.io/badge/Solidity-0.8.30-blue?logo=solidity" alt="Solidity Version"/>
  <img src="https://img.shields.io/badge/Foundry-Framework-orange" alt="Foundry"/>
  <img src="https://img.shields.io/badge/Network-Base%20Sepolia-blue" alt="Base Sepolia"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
</p>

## 📋 Table of Contents

- [Overview](#-overview)
- [Why Blockchain?](#-why-blockchain)
- [Why Base?](#-why-base)
- [Why IDRX?](#-why-idrx)
- [Smart Contract Architecture](#-smart-contract-architecture)
- [Getting Started](#-getting-started)
- [Environment Setup](#%EF%B8%8F-environment-setup)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Makefile Commands](#%EF%B8%8F-makefile-commands)
- [Minting Mock Tokens](#-minting-mock-tokens)
- [Deployed Contracts](#-deployed-contracts)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**CrowdFUNding** is a gamified crowdfunding platform built on the Base blockchain. We've reimagined the traditional crowdfunding experience by adding game-like elements to make donating more engaging and rewarding!

### ✨ Key Features

- **🎯 Campaign Creation**: Create fundraising campaigns with target amounts and track progress
- **💰 Multi-Token Donations**: Support for native currency and ERC20 tokens (IDRX & USDC)
- **🏆 Achievement Badges**: Mint NFT badges as achievements for donors and campaign milestones
- **🔒 Security First**: Built with OpenZeppelin's battle-tested contracts including ReentrancyGuard

---

## 💡 Why Blockchain?

Traditional crowdfunding platforms face significant challenges: **lack of transparency**, **high fees**, and **trust issues**. Blockchain technology solves these problems:

| Problem                        | Blockchain Solution                                 |
| ------------------------------ | --------------------------------------------------- |
| **Opaque fund usage**          | All transactions are publicly verifiable on-chain   |
| **High platform fees** (5-15%) | Direct peer-to-peer donations with minimal gas fees |
| **Geographical restrictions**  | Borderless donations from anywhere in the world     |
| **Fund misappropriation**      | Immutable records ensure accountability             |
| **Slow withdrawals**           | Instant fund access for campaign creators           |

With blockchain, every donation is **transparent**, **traceable**, and **trustless** — donors can verify exactly where their money goes.

---

## ⚡ Why Base?

We chose **Base** as our primary blockchain for several compelling reasons:

### 🚀 Performance & Cost

- **Low gas fees** — Up to 10x cheaper than Ethereum mainnet
- **Fast transactions** — Near-instant finality for smooth user experience
- **Scalable** — Built on Optimism's battle-tested OP Stack

### 🏛️ Security & Trust

- **Backed by Coinbase** — Leverages Coinbase's security expertise and reputation
- **Ethereum security** — Inherits Ethereum's robust security as an L2
- **Decentralized** — Committed to progressive decentralization

### 🌍 Ecosystem & Adoption

- **Growing ecosystem** — Rapidly expanding developer and user community
- **Easy onboarding** — Seamless integration with Coinbase wallet
- **EVM compatible** — Easy migration of existing Solidity code

Base provides the perfect balance of **security**, **speed**, and **cost-efficiency** for a crowdfunding platform.

---

## 🇮🇩 Why IDRX?

**IDRX** is Indonesia's first and largest rupiah-pegged stablecoin, making it the ideal currency for our platform:

### 💰 Local Currency Stability

- **1:1 pegged to IDR** — Donors contribute in familiar currency values
- **No forex volatility** — Campaign targets remain stable in local terms
- **Accessible amounts** — Small donations feel meaningful (not 0.0001 ETH)

### 🌏 Indonesian Market Focus

- **270M+ population** — Massive potential donor base
- **Growing crypto adoption** — Indonesia ranks 3rd globally in crypto adoption
- **Financial inclusion** — Reaches underbanked populations via mobile wallets

### 🔗 Technical Benefits

- **ERC20 compatible** — Seamless integration with Base ecosystem
- **2 decimal places** — Mirrors actual IDR for intuitive amounts
- **Regulated** — Compliant with Indonesian financial regulations

By supporting **IDRX alongside USDC**, we enable both **local Indonesian donors** and **international supporters** to contribute effortlessly.

---

## 🏗 Smart Contract Architecture

This project consists of **4 main smart contracts**:

### 1. **Campaign.sol** - Core Crowdfunding Contract

The heart of the platform. Manages all crowdfunding campaigns.

| Function            | Description                                                             |
| ------------------- | ----------------------------------------------------------------------- |
| `createCampaign()`  | Create a new fundraising campaign with name, creator, and target amount |
| `donate()`          | Donate native currency or ERC20 tokens to a campaign                    |
| `withdraw()`        | Campaign owners can withdraw collected funds                            |
| `getCampaignInfo()` | Retrieve campaign details (name, balance, target, etc.)                 |

**Features:**

- Supports both native currency and ERC20 token donations
- ReentrancyGuard protection for secure withdrawals
- Event emissions for donation tracking

### 2. **Badge.sol** - Achievement NFT Contract

ERC721-based NFT contract for minting achievement badges.

| Function         | Description                               |
| ---------------- | ----------------------------------------- |
| `mintBadge()`    | Mint a new achievement badge (owner only) |
| `getBadgeInfo()` | Get badge details by token ID             |

**Use Cases:**

- First donation badges
- Milestone achievement badges
- Campaign completion badges

### 3. **MockIDRX.sol** - Mock IDRX Token

A mock ERC20 token simulating IDRX (Indonesian Rupiah stablecoin).

| Property | Value |
| -------- | ----- |
| Name     | IDRX  |
| Symbol   | IDRX  |
| Decimals | 2     |

### 4. **MockUSDC.sol** - Mock USDC Token

A mock ERC20 token simulating USDC (USD Coin).

| Property | Value |
| -------- | ----- |
| Name     | USDC  |
| Symbol   | USDC  |
| Decimals | 6     |

> ⚠️ **Note**: The Mock IDRX and Mock USDC tokens are used **only for simulation and testing purposes**. In production, you would integrate with the actual IDRX and USDC token contracts.

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Git](https://git-scm.com/)
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (includes forge, cast, anvil)

**Verify Foundry is installed correctly:**

```bash
forge --version
```

You should see output like `forge 0.2.0 (...)` or similar.

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/CrowdFUNding-Base/SC.git
   cd SC
   ```

2. **Install dependencies**

   ```bash
   forge install
   ```

3. **Build the contracts**

   ```bash
   forge build
   ```

4. **Run tests to verify everything is working**

   ```bash
   forge test
   ```

   If all tests pass ✅, you're ready to go!

---

## ⚙️ Environment Setup

Create a `.env` file in the root directory with the following variables:

```env
# RPC URL for Base Sepolia network
BASE_RPC_URL=your_base_sepolia_rpc_url

# Etherscan API key for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key

# Private key for local Anvil deployment (mock - safe for testing)
LOCAL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Private key for deploying to Base Sepolia (use your actual wallet key)
PRIVATE_KEY=your_private_key
```

### 🔑 How to Retrieve Environment Keys

| Variable            | How to Get                                                                                                                          |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `BASE_RPC_URL`      | Sign up at [Alchemy](https://alchemy.com) or [Infura](https://infura.io) and create a Base Sepolia app. Copy the HTTP endpoint URL. |
| `ETHERSCAN_API_KEY` | Register at [Basescan](https://basescan.org) → Go to API Keys → Create a new API key                                                |
| `LOCAL_PRIVATE_KEY` | This is the default Anvil Account #0 private key. Safe for local testing only!                                                      |
| `PRIVATE_KEY`       | Export from your wallet (MetaMask: Account Details → Export Private Key). **Never share this!**                                     |

> ⚠️ **Security Warning**: Never commit your `.env` file or share your private keys. Add `.env` to your `.gitignore`.

---

## 🧪 Testing

Run the complete test suite:

```bash
forge test
```

Run tests with verbose output:

```bash
forge test -vvv
```

Run a specific test:

```bash
forge test --match-test testDonate -vvv
```

Generate gas report:

```bash
forge test --gas-report
```

### Test Coverage

The test suite includes:

- ✅ Campaign creation tests
- ✅ Native currency donation tests
- ✅ ERC20 token donation tests
- ✅ Withdrawal authorization tests
- ✅ Reentrancy attack protection tests
- ✅ Badge minting tests

---

## 🚀 Deployment

### Option 1: Local Deployment (Anvil)

1. **Start a local Anvil node** (in a separate terminal):

   ```bash
   anvil
   ```

2. **Deploy to local network**:
   ```bash
   make local-deploy
   ```

### Option 2: Base Sepolia Deployment

1. **Ensure your `.env` file is configured** with `BASE_RPC_URL` and `PRIVATE_KEY`

2. **Deploy to Base Sepolia**:

   ```bash
   make base-deploy
   ```

3. **Deploy with contract verification**:
   ```bash
   make base-deploy-verify
   ```

---

## ⚙️ Makefile Commands

The Makefile provides convenient shortcuts for common operations:

| Command                   | Environment  | Description                                    |
| ------------------------- | ------------ | ---------------------------------------------- |
| `make local-dry`          | Local        | Simulates deployment script locally (dry run)  |
| `make local-deploy`       | Local        | Deploys contracts to local Anvil node          |
| `make base-dry`           | Base Sepolia | Simulates deployment on Base Sepolia (dry run) |
| `make base-deploy`        | Base Sepolia | Deploys contracts to Base Sepolia              |
| `make base-deploy-verify` | Base Sepolia | Deploys and verifies contracts on Basescan     |

### Usage Examples

```bash
# Test your deployment locally first
make local-dry

# Start anvil in another terminal, then deploy
make local-deploy

# Dry run on Base Sepolia (simulation only)
make base-dry

# Actually deploy to Base Sepolia
make base-deploy

# Deploy and verify on Basescan
make base-deploy-verify
```

---

## 💵 Minting Mock Tokens

For testing and simulation purposes, we use **Mock IDRX** and **Mock USDC** tokens. These mock tokens allow you to test the donation flow without using real assets.

> 📝 **Important**: The Mock IDRX and Mock USDC are **simulation tokens only**. They are not the real IDRX or USDC tokens and have no real-world value. Use them solely for testing the crowdfunding flow.

### Minting Tokens via Cast

After deploying the mock tokens, you can mint tokens using Foundry's `cast` command:

**Mint Mock IDRX:**

```bash
cast send <MOCK_IDRX_ADDRESS> "mint(address,uint256)" <YOUR_WALLET_ADDRESS> <AMOUNT> --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

**Mint Mock USDC:**

```bash
cast send <MOCK_USDC_ADDRESS> "mint(address,uint256)" <YOUR_WALLET_ADDRESS> <AMOUNT> --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

### Example (Local Anvil):

```bash
# Mint 1000 IDRX (remember: 2 decimals, so 100000 = 1000 IDRX)
cast send 0x4a49f09fAfA1c493E5FC12dA89Ae8E0193E7e8AE "mint(address,uint256)" 0xYourWallet 100000 --rpc-url http://127.0.0.1:8545 --private-key $LOCAL_PRIVATE_KEY

# Mint 1000 USDC (remember: 6 decimals, so 1000000000 = 1000 USDC)
cast send 0xCCEEf0548658839637E5805E39bd52807792C4B9 "mint(address,uint256)" 0xYourWallet 1000000000 --rpc-url http://127.0.0.1:8545 --private-key $LOCAL_PRIVATE_KEY
```

---

## 📍 Deployed Contracts

All contracts are deployed on **Base Sepolia Testnet**:

| Contract      | Address                                      |
| ------------- | -------------------------------------------- |
| **Mock IDRX** | `0x4a49f09fAfA1c493E5FC12dA89Ae8E0193E7e8AE` |
| **Mock USDC** | `0xCCEEf0548658839637E5805E39bd52807792C4B9` |
| **Campaign**  | `0x59278eCD1805aB880A7fC83840d2d36DCc6697c9` |
| **Badge**     | `0x25076a7eaB3ca6295B3FCF6A026C2cf94BaF24e4` |

### View on Basescan

- [Mock IDRX](https://sepolia.basescan.org/address/0x4a49f09fAfA1c493E5FC12dA89Ae8E0193E7e8AE)
- [Mock USDC](https://sepolia.basescan.org/address/0xCCEEf0548658839637E5805E39bd52807792C4B9)
- [Campaign](https://sepolia.basescan.org/address/0x59278eCD1805aB880A7fC83840d2d36DCc6697c9)
- [Badge](https://sepolia.basescan.org/address/0x25076a7eaB3ca6295B3FCF6A026C2cf94BaF24e4)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by the CrowdFUNding Team
</p>

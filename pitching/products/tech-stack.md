# 9. Tech Stack

Our technology stack is carefully chosen for **security**, **scalability**, and **exceptional user experience**, leveraging the latest technologies and the Base ecosystem.

## Stack Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TECH STACK                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        FRONTEND                                       │   │
│  │  Next.js 16 │ React 19 │ TypeScript │ TailwindCSS 4                  │   │
│  │  Privy │ RainbowKit │ OnchainKit │ wagmi │ viem │ Framer Motion      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                        │
│                             REST/GraphQL/RPC                                 │
│                                     ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         BACKEND                                       │   │
│  │  Express.js │ TypeScript │ PostgreSQL │ Passport.js │ JWT            │   │
│  │  LangChain │ Google Generative AI │ Ethers.js v5                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                        │
│                               Auto-Sync                                      │
│                                     ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         INDEXER                                       │   │
│  │  Ponder v0.16 │ TypeScript │ Hono │ GraphQL │ viem                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                        │
│                            Event Subscription                                │
│                                     ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      SMART CONTRACTS                                  │   │
│  │  Solidity 0.8.30 │ Foundry │ OpenZeppelin │ Base Sepolia             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Frontend (FE)

The frontend is built with modern React technologies, prioritizing performance, type safety, and seamless Web3 integration. It serves as the user-facing layer where donors and campaign creators interact with the platform.

### Core Framework

These are the foundational packages that power the frontend application:

| Package | Version | Purpose |
|---------|---------|---------|
| **Next.js** | 16.0.7 | React framework with App Router |
| **React** | 19.2.0 | UI component library |
| **TypeScript** | ^5 | Type-safe JavaScript |

### Styling & UI

The visual layer uses utility-first CSS with smooth animations to create a premium, responsive experience:

| Package | Version | Purpose |
|---------|---------|---------|
| **TailwindCSS** | ^4 | Utility-first CSS framework |
| **Framer Motion** | ^12.29.0 | Animation library |
| **Lucide React** | ^0.562.0 | Icon components |
| **React Icons** | ^5.5.0 | Additional icon set |
| **class-variance-authority** | ^0.7.1 | Component variants |
| **clsx** | ^2.1.1 | Conditional class names |
| **tailwind-merge** | ^3.4.0 | Merge Tailwind classes |

### Web3 & Wallet Integration

These packages enable blockchain connectivity, allowing users to connect wallets and interact with smart contracts:

| Package | Version | Purpose |
|---------|---------|---------|
| **@privy-io/react-auth** | ^3.12.0 | Social + wallet authentication |
| **@rainbow-me/rainbowkit** | ^2.2.10 | Wallet connection UI |
| **@coinbase/onchainkit** | ^1.1.2 | Base-native components |
| **wagmi** | ^2.19.5 | React hooks for Ethereum |
| **viem** | ^2.45.0 | Low-level blockchain utilities |
| **@tanstack/react-query** | ^5.90.20 | Data fetching & caching |

### Social Integration

Social login and Farcaster integration packages for seamless onboarding:

| Package | Version | Purpose |
|---------|---------|---------|
| **@farcaster/miniapp-sdk** | ^0.2.2 | Farcaster social integration |
| **@react-oauth/google** | ^0.13.4 | Google OAuth client |

### HTTP Client

| Package | Version | Purpose |
|---------|---------|---------|
| **axios** | ^1.13.4 | HTTP requests to backend |

---

## Backend (BE)

The backend serves as the API layer and data cache, bridging the frontend with blockchain data. It handles authentication, off-chain storage, and synchronization with the indexer.

### Core Framework

The server is built on Express.js with TypeScript for type safety:

| Package | Version | Purpose |
|---------|---------|---------|
| **Express** | ^4.21.2 | Web server framework |
| **TypeScript** | ^5.8.3 | Type-safe JavaScript |
| **ts-node** | ^10.9.2 | TypeScript execution |
| **nodemon** | ^3.1.10 | Development hot-reload |

### Database

PostgreSQL is used for persistent storage of off-chain campaign data and user information:

| Package | Version | Purpose |
|---------|---------|---------|
| **pg** | ^8.16.3 | PostgreSQL client |
| **@types/pg** | ^8.16.0 | PostgreSQL type definitions |

### Authentication

Multiple authentication strategies support both traditional and Web3 users:

| Package | Version | Purpose |
|---------|---------|---------|
| **passport** | ^0.7.0 | Authentication middleware |
| **passport-google-oauth20** | ^2.0.0 | Google OAuth strategy |
| **jsonwebtoken** | ^9.0.2 | JWT generation/validation |
| **express-session** | ^1.18.1 | Session management |
| **bcrypt** | ^6.0.0 | Password hashing |

### AI/LLM Integration

AI capabilities for campaign description generation and content moderation:

| Package | Version | Purpose |
|---------|---------|---------|
| **@google/genai** | ^1.9.0 | Google Generative AI |
| **@langchain/core** | ^0.3.62 | LangChain framework |
| **@langchain/google-genai** | ^0.2.14 | LangChain + Google AI |

### Blockchain

Ethers.js connects the backend to the blockchain for transaction verification:

| Package | Version | Purpose |
|---------|---------|---------|
| **ethers** | ^5.8.0 | Ethereum library |

### Utilities

Supporting libraries for common backend operations:

| Package | Version | Purpose |
|---------|---------|---------|
| **axios** | ^1.12.2 | HTTP client |
| **cors** | ^2.8.5 | Cross-origin resource sharing |
| **dotenv** | ^16.5.0 | Environment variables |
| **cookie-parser** | ^1.4.7 | Cookie handling |
| **express-validator** | ^7.2.1 | Input validation |
| **qrcode** | ^1.5.4 | QR code generation |
| **crypto-js** | ^4.2.0 | Encryption utilities |
| **bignumber.js** | ^9.3.0 | Big number handling |

### Deployment

| Platform | Purpose |
|----------|---------|
| **Vercel** | Serverless deployment |

---

## Smart Contracts (SC)

The smart contracts form the trustless foundation of the platform, handling all financial operations on-chain with full transparency.

### Language & Framework

Development uses Solidity with Foundry for fast iteration:

| Tool | Version | Purpose |
|------|---------|---------|
| **Solidity** | ^0.8.30 | Smart contract language |
| **Foundry** | Latest | Development, testing, deployment |

### Architecture

- **Pattern**: Singleton (one contract manages all campaigns)
- **Gas Optimization**: Single deployment, shared state
- **Security**: ReentrancyGuard, SafeERC20

### Contracts

The deployed contracts and their responsibilities:

| Contract | Standard | Purpose |
|----------|----------|---------|
| **Campaign.sol** | Custom | Core crowdfunding logic with auto-swap |
| **Badge.sol** | ERC721 | Achievement NFT minting |
| **MockSwap.sol** | Custom | Token exchange router |
| **MockIDRX.sol** | ERC20 | Indonesian Rupiah stablecoin (2 decimals) |
| **MockUSDC.sol** | ERC20 | USD Coin mock (6 decimals) |

### Dependencies (OpenZeppelin)

Battle-tested security libraries from OpenZeppelin:

| Library | Purpose |
|---------|---------|
| **ReentrancyGuard** | Prevent reentrancy attacks |
| **IERC20** | ERC20 interface |
| **SafeERC20** | Safe token transfers |
| **ERC721** | NFT standard |
| **Ownable** | Access control |

### Network

All contracts are deployed on Base Sepolia testnet:

| Chain | ChainId | Explorer |
|-------|---------|----------|
| **Base Sepolia** | 84532 | [basescan.org](https://sepolia.basescan.org) |

---

## Indexer

The indexer listens to blockchain events and makes on-chain data queryable through APIs. It serves as the bridge between the blockchain and the backend.

### Core Framework

Ponder provides the indexing infrastructure:

| Package | Version | Purpose |
|---------|---------|---------|
| **Ponder** | ^0.16.2 | Blockchain indexing framework |
| **TypeScript** | ^5.3.2 | Type-safe JavaScript |

### API Layer

The indexed data is exposed through both REST and GraphQL endpoints:

| Package | Version | Purpose |
|---------|---------|---------|
| **Hono** | ^4.5.0 | Lightweight REST framework |
| **GraphQL** | Built-in | Query language for APIs |

### Blockchain

viem provides low-level blockchain interaction:

| Package | Version | Purpose |
|---------|---------|---------|
| **viem** | ^2.21.3 | Ethereum utilities |

### Database

The indexer supports different databases for development and production:

| Option | Default | Description |
|--------|---------|-------------|
| **SQLite** | Yes (dev) | Lightweight, file-based |
| **PostgreSQL** | Production | Scalable, managed |

---

## Development Tools

Code quality is maintained through linting and formatting tools.

### Linting & Formatting

These tools ensure consistent code style across the codebase:

| Tool | Purpose |
|------|---------|
| **ESLint** | JavaScript/TypeScript linting |
| **Prettier** | Code formatting |
| **eslint-config-next** | Next.js specific rules |
| **eslint-config-ponder** | Ponder specific rules |

### Build Tools

Build-time tools for compilation and asset processing:

| Tool | Purpose |
|------|---------|
| **PostCSS** | CSS processing |
| **Autoprefixer** | CSS vendor prefixes |
| **Foundry (forge)** | Solidity compilation |

---

## Infrastructure & Deployment

The platform is deployed across multiple cloud providers for reliability and performance.

### Recommended Providers

These are our recommended hosting providers for each component:

| Service | Provider | Purpose |
|---------|----------|---------|
| **RPC** | Alchemy / Infura | Blockchain node access |
| **Frontend Hosting** | Vercel | Next.js deployment |
| **Backend Hosting** | Vercel / Railway | Express.js deployment |
| **Indexer Hosting** | Railway / Render | Ponder deployment |
| **Database** | Supabase / Neon | PostgreSQL hosting |
| **Domain** | Cloudflare | DNS & CDN |

### Environment Requirements

Minimum versions required to run the development environment:

| Runtime | Version |
|---------|---------|
| **Node.js** | ≥18.14 |
| **pnpm/npm/yarn** | Latest |
| **Foundry** | Latest |

---

## Performance Characteristics

### Frontend

- Server-Side Rendering (SSR) with Next.js
- React Query caching (5s default)
- Tree-shaking with Webpack

### Backend

- Auto-sync every 30 seconds from Ponder
- PostgreSQL connection pooling
- JWT stateless authentication

### Smart Contracts

- Gas-efficient singleton pattern
- Minimal storage operations
- Event-based state tracking

### Indexer

- Real-time event processing
- Efficient SQL queries
- GraphQL for complex queries

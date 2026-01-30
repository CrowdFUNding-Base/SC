# CrowdFUNding Pitching Documentation

Welcome to the CrowdFUNding technical documentation! This folder contains all the information needed to understand, present, and run our gamified crowdfunding platform.

## Folder Structure

```
pitching/
├── introduction/              # Platform overview and problem-solution
├── products/                  # Product documentation and features
├── architecture/              # Technical architecture
├── how-to-run/                # Development guides
├── business/                  # Business documentation
├── missions/                  # Vision and goals
├── deployment/                # Deployment guides
├── additional-features/       # FAQ and extras
└── others/                    # Miscellaneous
```

---

## Quick Navigation

### For Judges/Evaluators

Start here to understand the platform:

1. **Overview**: [introduction/overview.md](./introduction/overview.md)
2. **Problem**: [introduction/problem.md](./introduction/problem.md)
3. **Solution**: [introduction/solution.md](./introduction/solution.md)
4. **How it Works**: [products/how-crowdfunding-works.md](./products/how-crowdfunding-works.md)
5. **Tech Stack**: [products/tech-stack.md](./products/tech-stack.md)

### For Developers

Get up and running quickly:

1. **Quick Start**: [how-to-run/quick-start-guide.md](./how-to-run/quick-start-guide.md)
2. **System Architecture**: [architecture/system-architecture.md](./architecture/system-architecture.md)
3. **Smart Contract Guide**: [how-to-run/smart-contract-guide.md](./how-to-run/smart-contract-guide.md)
4. **Backend Guide**: [how-to-run/backend-guide.md](./how-to-run/backend-guide.md)
5. **Frontend Guide**: [how-to-run/frontend-guide.md](./how-to-run/frontend-guide.md)
6. **Indexer Guide**: [how-to-run/indexer-guide.md](./how-to-run/indexer-guide.md)

### For Technical Deep-Dive

Understand the architecture:

1. **Smart Contract Architecture**: [architecture/smart-contract-architecture.md](./architecture/smart-contract-architecture.md)
2. **System Architecture**: [architecture/system-architecture.md](./architecture/system-architecture.md)
3. **Data Flow**: [architecture/data-flow.md](./architecture/data-flow.md)

### Features Documentation

Detailed documentation for each core feature:

1. **Seedless Access**: [products/feature-seedless-access.md](./products/feature-seedless-access.md)
2. **Fiat Gateway**: [products/feature-fiat-gateway.md](./products/feature-fiat-gateway.md)
3. **Borderless Rail**: [products/feature-borderless-rail.md](./products/feature-borderless-rail.md)
4. **Gamification**: [products/feature-gamification.md](./products/feature-gamification.md)
5. **Settlement**: [products/feature-settlement.md](./products/feature-settlement.md)

---

## Key Highlights

### Why CrowdFUNding?

| Problem | Our Solution |
|---------|--------------|
| Opaque fund usage | All transactions on blockchain |
| High platform fees (5-15%) | Minimal gas fees on Base |
| Geographic restrictions | Borderless with crypto |
| Complex crypto onboarding | Google login + embedded wallets |

### Tech Stack at a Glance

| Layer | Technology |
|-------|------------|
| **Frontend** | Next.js 16, React 19, TailwindCSS 4 |
| **Backend** | Express.js, PostgreSQL, Passport.js |
| **Smart Contracts** | Solidity 0.8.30, Foundry, OpenZeppelin |
| **Indexer** | Ponder, GraphQL, Hono |
| **Blockchain** | Base Sepolia (L2) |

### Deployed Contracts

| Contract | Address |
|----------|---------|
| Campaign | `0x44e87aa98d721Dbcf368690bF5aAb1F3dD944dA9` |
| Badge | `0xaE32Df9Fb677aE68C5A1F956761a42e269Ebdc99` |
| MockSwap | `0x554366984fD2f5D82c753F91357d80c29F887F17` |
| MockIDRX | `0x387551ac55Bb6949d44715D07880f8c6260934B6` |
| MockUSDC | `0x1b929eB40670aA4e0D757d45cA9aea2311a25a97` |

---

## Document Conventions

All documentation in this folder follows these conventions:

- **Mermaid diagrams** are used for architecture and flow visualizations
- **Descriptions** precede all diagrams and tables for context
- **Tables** summarize configuration and reference information
- **Code blocks** show actual implementation examples
- Each component is treated as an **independent repository**

---

## Contact

For questions about the technical implementation, please reach out to the CrowdFUNding team.

---

Made with love by the CrowdFUNding Team

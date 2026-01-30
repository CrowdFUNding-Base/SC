# CrowdFUNding Pitching Documentation

Welcome to the CrowdFUNding technical documentation! This folder contains all the information needed to understand, present, and run our gamified crowdfunding platform.

## Folder Structure

```
pitching/
├── Introduction/              # Platform overview and problem-solution
├── Products/                  # Product documentation
├── Architecture/              # Technical architecture
├── How to Run/                # Development guides
├── Business/                  # Business documentation
├── Missions/                  # Vision and goals
├── Deployment/                # Deployment guides
└── Others/                    # Miscellaneous
```

---

## Quick Navigation

### For Judges/Evaluators

Start here to understand the platform:

1. **Overview**: [Introduction/1. Overview.md](./Introduction/1.%20Overview.md)
2. **Problem**: [Introduction/2. Problem.md](./Introduction/2.%20Problem.md)
3. **Solution**: [Introduction/3. Solution.md](./Introduction/3.%20Solution.md)
4. **How it Works**: [Products/8. How CrowdFUNding Works.md](./Products/8.%20How%20CrowdFUNding%20Works.md)
5. **Tech Stack**: [Products/9. Tech Stack.md](./Products/9.%20Tech%20Stack.md)

### For Developers

Get up and running quickly:

1. **Quick Start**: [How to Run/5. Quick Start Guide.md](./How%20to%20Run/5.%20Quick%20Start%20Guide.md)
2. **System Architecture**: [Architecture/2. System Architecture.md](./Architecture/2.%20System%20Architecture.md)
3. **Smart Contract Guide**: [How to Run/1. Smart Contract Guide.md](./How%20to%20Run/1.%20Smart%20Contract%20Guide.md)
4. **Backend Guide**: [How to Run/2. Back End Guide.md](./How%20to%20Run/2.%20Back%20End%20Guide.md)
5. **Frontend Guide**: [How to Run/3. Front End Guide.md](./How%20to%20Run/3.%20Front%20End%20Guide.md)
6. **Indexer Guide**: [How to Run/4. Indexer Guide.md](./How%20to%20Run/4.%20Indexer%20Guide.md)

### For Technical Deep-Dive

Understand the architecture:

1. **Smart Contract Architecture**: [Architecture/1. Smart Contract Architecture.md](./Architecture/1.%20Smart%20Contract%20Architecture.md)
2. **System Architecture**: [Architecture/2. System Architecture.md](./Architecture/2.%20System%20Architecture.md)
3. **Data Flow**: [Architecture/3. Data Flow.md](./Architecture/3.%20Data%20Flow.md)

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

# 6. Base Ecosystem Utilization

Our technical architecture is deeply integrated with the Base stack to ensure speed, affordability, and seamless user experience.

## 1. Base Layer-2 Infrastructure (The Foundation)

- **Low-Cost Scalability**: CrowdFUNding utilizes the OP Stack's optimistic rollup technology. This ensures that even a **Rp 10,000 ($0.65)** donation is viable, as gas fees are negligible (~$0.01).
- **Core Logic**: All `CampaignFactory`, `DonationTracking`, and `PetEvolution` contracts are deployed directly on Base, ensuring full transparency.

## 2. Seamless Authentication (The UX Layer)

- **Google OAuth 2.0**: The platform uses **Google OAuth 2.0** for social login, handled securely on the backend via Passport.js. This provides a familiar "Sign in with Google" experience.
- **RainbowKit Integration**: For crypto-native users, **RainbowKit** provides wallet connection support for MetaMask, Coinbase Wallet, WalletConnect, and 100+ wallets.
- **Dual Authentication**: Users can login with Google, connect a wallet, or both - and optionally link their wallet to their Google account for a unified profile.
- **Identity & Profile**: User profiles, balances, and impact stats are displayed in a beautiful, standardized UI.

## 3. IDRX Integration (The Settlement Layer)

- **Native Currency**: The entire protocol is hardcoded to recognize **IDRX** as the base settlement unit.
- **DEX Aggregation**: The system interacts with Base-native DEXs (like Uniswap on Base or Aerodrome) to facilitate the atomic swaps of `USDC/ETH` $\rightarrow$ `IDRX` for global donors.

## 4. Smart Wallet Capabilities (Future)

- **Paymasters**: In future iterations, CrowdFUNding plans to utilize Base's Paymaster capabilities to fully subsidize gas for first-time donors, achieving a truly "0-friction" experience.

# Feature: Easy Authentication

**As a user**, I can login with my Google account or my existing Crypto Wallet, making the platform accessible regardless of my technical expertise.

## Overview

Easy Auth bridges the gap between Web2 and Web3. It allows users to interact with the blockchain using familiar credentials (email/socials) via Account Abstraction, while still offering full control for power users with MetaMask/Rainbow.

## What it solves

- **Onboarding Friction**: Eliminates the "install wallet -> save seed phrase" hurdle for new users.
- **Accessibility**: Allows grandma to donate using her email, while her funds are still secured on-chain.

## Traditional vs CrowdFUNding

| Feature                  | Traditional Web2     | Pure Web3      | CrowdFUNding (Hybrid)   |
| :----------------------- | :------------------- | :------------- | :---------------------- |
| **Login**                | Email/Pass           | Wallet Connect | Both                    |
| **Security**             | Centralized Database | User Custody   | Flexible (Smart Wallet) |
| **Time to First Action** | Fast                 | Slow (Setup)   | Fast                    |

## How it works

1.  **User Visits Site**: Choose "Login with Google" or "Connect Wallet".
2.  **Web2 Flow**:
    - User authenticates via OAuth.
    - system generates a Smart Account (embedded wallet) for them.
3.  **Web3 Flow**:
    - Standard connection (RainbowKit/OnchainKit).
4.  **Session**: Unified session token allows interaction with the app.

## Activity Diagram

[User: Click Login] -> [Choice: Web2 or Web3?]
-> (Web2) -> [Google Auth] -> [Create/Load Smart Account] -> [Logged In]
-> (Web3) -> [Sign Message] -> [Logged In]

## Key Benefits

- **Inclusivity**: Open to 100% of internet users, not just the 1% crypto-natives.
- **Flexibility**: Users can graduate from Web2 login to self-custody later.

# Feature: Borderless Transactions

**As a user**, I can donate to a local Indonesian campaign using my Global ETH or USDC wallet without worrying about exchange rates or bank transfers.

## Overview

The Borderless Transaction feature acts as a universal adapter for donations. It allows the platform to accept various cryptocurrencies (ETH, USDC, DAI) and automatically converts them into the campaign's base currency (IDRX) in a single transaction.

## What it solves

- **For Donors**: Removes the need to manually swap tokens on a DEX before donating.
- **For Campaigners**: Guarantees they receive a stable asset (IDRX) ready for local use, shielding them from crypto volatility.
- **For the Ecosystem**: Increases volume on Base DEXs and deepens IDRX liquidity.

## Traditional vs CrowdFUNding

| Feature          | Traditional Swift/Bank   | CrowdFUNding on Base                    |
| :--------------- | :----------------------- | :-------------------------------------- |
| **Speed**        | 3-5 Business Days        | Seconds (~2s block time)                |
| **Cost**         | High ($20-$50 + FX fees) | Negligible (~$0.01 gas + 0.3% swap fee) |
| **Transparency** | Low (Bank Internal)      | High (Fully On-Chain)                   |

## How it works

1.  **Select Token**: User selects "Donate 10 USDC".
2.  **Approve**: User approves the contract to spend USDC.
3.  **Donate Call**: The `donate()` function is called.
4.  **Auto-Swap**: The contract interacts with a Router (e.g., Uniswap) to swap 10 USDC -> IDRX.
5.  **Record**: The equivalent IDRX amount is credited to the campaign balance and the user's donation history.

## Activity Diagram

[User: Select Token] -> [Approve Token] -> [Smart Contract: Receive Token] -> [DEX: Swap to IDRX] -> [Campaign Balance: Credit IDRX] -> [Mint Receipt NFT]

## Key Benefits

- **Global Reach**: Open local problems to global solutions.
- **Stability**: Recipients sleep soundly knowing their funds are in stable IDRX.
- **Efficiency**: One-click experience for the user.

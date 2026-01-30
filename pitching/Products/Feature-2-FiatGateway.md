# Feature 2: Instant Fiat Gateway (Local Rail)

**"Scan QRIS, Settle On-Chain."**

## Overview

The Instant Fiat Gateway allows local donors to use their favorite daily banking apps (GoPay, OVO, BCA, etc.) to contribute. The magic happens in the background: the fiat payment is instantly converted and settled as **IDRX** on the Base network.

## What it solves

- **Financial Leakage**: Bypasses the 12.66% fees often associated with traditional cross-border or high-friction payment gateways.
- **Liquidity**: Ensures immediate settlement in a stable asset (IDRX), avoiding the 3-5 day bank clearing times.

## Technical Flow

`[User Scans QRIS] -> [IDR Payment Processed] -> [Backend Verifies] -> [Auto-Mint IDRX to Campaign Vault] -> [Update On-Chain Balance]`

## Why it matters

This feature meets the user where they are. It doesn't ask them to change their behavior (scanning QRIS is daily life in Indonesia) but upgrades the underlying infrastructure to be faster, cheaper, and transparent.

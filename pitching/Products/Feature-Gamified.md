# Feature: Gamified Donation

**As a user**, I can earn XP, badges, and tangible rewards for my charitable contributions, tracking my impact on a global leaderboard.

## Overview

Gamification turns philanthropy into an engaging loop. Instead of just a "Thank You" email, donors receive dynamic NFTs ("Proof of Contribution") that evolve based on their donation volume and frequency.

## What it solves

- **Low Engagement**: Fixes the "donate and leave" problem.
- **Lack of Recognition**: Provides permanent, public proof of a donor's generosity.
- **Community Building**: Creates a shared sense of progression among donors.

## Traditional vs CrowdFUNding

| Feature         | Traditional   | CrowdFUNding              |
| :-------------- | :------------ | :------------------------ |
| **Reward**      | Email Receipt | Evolving 3D NFT           |
| **Status**      | Name on list  | Leaderboard Rank & Badges |
| **Interaction** | None          | Quests, Streaks, Voting   |

## How it works

1.  **Donation Event**: User makes a donation.
2.  **Mint/Update**:
    - _First Time_: Mints a "Seed" NFT.
    - _Repeat_: Updates metadata (Seed -> Sapling -> Tree) based on cumulative IDRX value.
3.  **XP Calculation**: Off-chain or On-chain logic calculates XP (1000 IDRX = 1 XP).
4.  **Leaderboard**: Indexer updates the Global and Campaign-specific leaderboards.

## Activity Diagram

[User: Donate] -> [Smart Contract: Process] -> [NFT Contract: Check Balance] -> [NFT Contract: Mint or Evolve Token] -> [Frontend: Show 'Level Up' Animation]

## Key Benefits

- **Retention**: Users return to "level up" their impact.
- **Virality**: Users share their cool 3D badges on social media.
- **Value**: NFTs can unlock exclusive content or voting rights in the future.

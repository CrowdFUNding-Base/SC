# 2. Backend Guide

This guide provides comprehensive instructions for setting up and running the CrowdFUNding backend server, including its architecture and key components.

## Overview

The backend is an **Express.js** server built with TypeScript that serves as the central API layer for the CrowdFUNding platform. It handles authentication, caches blockchain data, and stores off-chain information.

**Key Responsibilities:**
- User authentication (Google OAuth, wallet-based login)
- PostgreSQL database for off-chain data and caching
- Automatic synchronization with Ponder indexer
- REST API for the frontend application
- Achievement and badge management
- Share link generation for social features

## Architecture

The backend follows a layered architecture pattern that separates concerns and improves maintainability.

```mermaid
flowchart TB
    subgraph API["API Layer"]
        Routes["Express Routes"]
        Middleware["Middleware\n(Auth, Validation, CORS)"]
    end

    subgraph Business["Business Layer"]
        AuthCtrl["Auth Controller"]
        VaultCtrl["Vault Controller"]
        ContribCtrl["Contribution Controller"]
        AchieveCtrl["Achievement Controller"]
        SyncCtrl["Sync Controller"]
    end

    subgraph Data["Data Layer"]
        Models["Sequelize Models"]
        PonderClient["Ponder API Client"]
    end

    subgraph External["External Services"]
        PostgreSQL[(PostgreSQL)]
        Ponder["Ponder Indexer"]
        Google["Google OAuth"]
    end

    Routes --> Middleware --> Business
    Business --> Data
    Models --> PostgreSQL
    PonderClient --> Ponder
    AuthCtrl --> Google
```

### Key Architectural Decisions

The following table explains the major architectural choices and their benefits:

| Decision | Implementation | Benefit |
|----------|---------------|---------|
| **Layered Architecture** | Routes → Controllers → Models | Separation of concerns, testability |
| **PostgreSQL Caching** | Store indexed data locally | Fast queries, reduced Ponder load |
| **Auto-Sync Service** | 30-second polling from Ponder | Near real-time data without WebSockets |
| **Passport.js Auth** | Google OAuth + JWT | Flexible authentication strategies |

## Prerequisites

Before setting up the backend, ensure you have:

- **Node.js** v18 or higher
- **PostgreSQL** database (local or cloud-hosted)
- **npm**, **yarn**, or **pnpm**

## Project Structure

The backend uses a standard Express.js project structure with clear separation of concerns:

```
├── app.ts                    # Main entry point
├── config/
│   └── database.ts          # PostgreSQL connection config
├── controllers/
│   ├── achievementController.ts  # Badge/achievement logic
│   ├── authController.ts         # Authentication handlers
│   ├── contributionController.ts # QRIS payment handling
│   ├── shareController.ts        # Social sharing features
│   ├── syncController.ts         # Ponder data sync
│   └── vaultController.ts        # Campaign/vault CRUD
├── middleware/
│   └── auth.ts              # JWT authentication middleware
├── models/
│   ├── achievementModel.ts  # Achievement data model
│   ├── shareModel.ts        # Share link model
│   ├── userModel.ts         # User data model
│   └── vaultModel.ts        # Campaign/vault model
├── routes/
│   ├── auth.ts              # Authentication routes
│   ├── crowdfunding.ts      # Main API routes
│   └── sync.ts              # Sync endpoints
├── services/
│   └── autoSync.ts          # Background Ponder sync service
├── sql/                     # Database migrations
├── scripts/
│   ├── initialSync.ts       # Initial data sync script
│   └── setupDatabase.ts     # DB setup script
└── utils/                   # Utility functions
```

## Database Architecture

The backend uses PostgreSQL for persistent storage. The database schema includes both cached blockchain data and off-chain information.

```mermaid
erDiagram
    USERS {
        uuid id PK
        varchar email
        varchar wallet_address
        varchar name
        timestamp created_at
    }
    
    VAULTS {
        integer id PK
        varchar name
        varchar creator_name
        text description
        varchar image_url
        varchar owner
        decimal balance
        decimal target_amount
        timestamp created_at
    }
    
    ACHIEVEMENTS {
        uuid id PK
        uuid user_id FK
        integer vault_id FK
        varchar badge_type
        integer token_id
        timestamp earned_at
    }
    
    SHARES {
        uuid id PK
        varchar short_code UK
        integer vault_id FK
        uuid created_by FK
        integer click_count
        timestamp created_at
    }

    USERS ||--o{ ACHIEVEMENTS : "earns"
    USERS ||--o{ SHARES : "creates"
    VAULTS ||--o{ ACHIEVEMENTS : "triggers"
    VAULTS ||--o{ SHARES : "promotes"
```

### Data Sources

The backend combines data from multiple sources:

| Table | On-chain Data | Off-chain Data |
|-------|--------------|----------------|
| `vaults` | id, name, balance, target, owner | description, imageUrl, category |
| `users` | wallet_address | email, name, preferences |
| `achievements` | token_id (NFT) | badge_type, earned_at |
| `shares` | - | short_code, click_count |

## Environment Setup

Create a `.env` file in the project root with the following configuration:

```env
# ============================
# Server Configuration
# ============================
PORT=3300
NODE_ENV=development

# ============================
# Database (PostgreSQL)
# ============================
DATABASE_URL=postgresql://username:password@localhost:5432/crowdfunding

# ============================
# Authentication
# ============================
SESSION_SECRET=your-super-secret-session-key
JWT_SECRET=your-jwt-secret-key

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# ============================
# Frontend URL (for CORS)
# ============================
FRONTEND_URL=http://localhost:3000

# ============================
# Ponder Indexer
# ============================
PONDER_URL=http://localhost:42069

# ============================
# Blockchain Configuration
# ============================
RPC_URL=https://sepolia.base.org
PRIVATE_KEY=your-private-key-for-minting

# ============================
# AI Integration (Optional)
# ============================
GOOGLE_AI_API_KEY=your-google-ai-api-key
```

### How to Get Environment Keys

The following table provides instructions for obtaining each required key:

| Variable | How to Obtain |
|----------|---------------|
| `DATABASE_URL` | Create free PostgreSQL at [Supabase](https://supabase.com) or [Neon](https://neon.tech) |
| `GOOGLE_CLIENT_ID` | [Google Cloud Console](https://console.cloud.google.com) → APIs → Credentials |
| `RPC_URL` | [Alchemy](https://alchemy.com) or [Infura](https://infura.io) → Create Base Sepolia app |
| `PRIVATE_KEY` | Export from MetaMask (for badge minting) |
| `GOOGLE_AI_API_KEY` | [Google AI Studio](https://makersuite.google.com/app/apikey) |

## Installation

### Step 1: Install Dependencies

```bash
npm install
# or
yarn install
```

### Step 2: Database Setup

Run the database setup script to create required tables:

```bash
npm run db:setup
```

This creates the following tables:
- `users` - User accounts and preferences
- `vaults` - Campaign data (cached + off-chain)
- `achievements` - User badge records
- `shares` - Social share links

### Step 3: Initial Data Sync (Optional)

If you have an existing Ponder indexer running, sync historical data:

```bash
npm run sync:initial
```

## Running the Server

### Development Mode

Start the server with hot-reload enabled:

```bash
npm start
# or
npm run dev
```

The server will start at `http://localhost:3300`

### Production Build

For production deployment:

```bash
# Compile TypeScript
npm run build

# Start compiled version
node dist/app.js
```

## Auto-Sync Service

The backend includes a background service that automatically synchronizes data from the Ponder indexer every 30 seconds.

```mermaid
sequenceDiagram
    participant Timer as Interval Timer
    participant Sync as Sync Service
    participant Ponder as Ponder GraphQL
    participant DB as PostgreSQL

    loop Every 30 seconds
        Timer->>Sync: Trigger sync
        Sync->>Ponder: Query campaigns
        Ponder-->>Sync: Campaign data
        Sync->>DB: Upsert campaigns
        Sync->>Ponder: Query donations
        Ponder-->>Sync: Donation data
        Sync->>DB: Upsert donations
        Sync->>Sync: Log sync status
    end
```

The sync service is started automatically when the server boots:

```typescript
// services/autoSync.ts
export const startAutoSync = () => {
  // Initial sync on startup
  syncFromPonder();
  
  // Periodic sync every 30 seconds
  setInterval(syncFromPonder, 30000);
};
```

## API Endpoints

The backend exposes REST endpoints organized by feature. All routes are prefixed with `/crowdfunding`.

### Authentication Endpoints

These endpoints handle user login and session management:

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/google-login` | Google OAuth login | No |
| POST | `/wallet-login` | Wallet-based login | No |
| GET | `/auth/status` | Check session status | Yes |
| POST | `/auth/logout` | End session | Yes |

### Campaign (Vault) Endpoints

These endpoints manage crowdfunding campaigns:

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/vaults` | List all campaigns | No |
| GET | `/vault/:id` | Get single campaign | No |
| POST | `/vault/create` | Create campaign | Yes |
| PATCH | `/vault/:id` | Update campaign | Yes |
| GET | `/vaults/statistics` | Platform stats | No |
| GET | `/vault/:id/donations` | Campaign donations | No |

### Achievement Endpoints

These endpoints manage user achievements and badges:

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/achievements` | Get user achievements | Yes |
| GET | `/achievements/:id` | Get specific achievement | Yes |
| POST | `/achievements` | Create achievement | Yes |
| POST | `/achievements/:id/mint` | Mint as NFT | Yes |
| GET | `/achievements/campaign/:id` | Campaign achievements | No |

### Share Endpoints

These endpoints handle social sharing features:

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/share/generate` | Create share link | Yes |
| GET | `/share/:shortCode` | Redirect to campaign | No |
| GET | `/share/:shortCode/qr` | Generate QR code | No |
| GET | `/share/:shortCode/stats` | Link statistics | No |

## Testing API

Use cURL or HTTPie to test the API endpoints:

```bash
# Get all campaigns
curl http://localhost:3300/crowdfunding/vaults

# Get single campaign
curl http://localhost:3300/crowdfunding/vault/1

# Check sync status
curl http://localhost:3300/api/sync/status
```

## Deployment

### Vercel

The project includes `vercel.json` for serverless deployment:

```json
{
  "version": 2,
  "builds": [{ "src": "app.ts", "use": "@vercel/node" }],
  "routes": [{ "src": "/(.*)", "dest": "app.ts" }]
}
```

Deploy with:
```bash
vercel --prod
```

### Railway / Render

For platform deployment:

1. Connect your GitHub repository
2. Set environment variables in the dashboard
3. Configure:
   - Build command: `npm run build`
   - Start command: `npm start`

## Troubleshooting

### Database Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Solution:** Ensure PostgreSQL is running and `DATABASE_URL` is correct.

### CORS Errors

**Error:** `Access-Control-Allow-Origin header missing`

**Solution:** Add your frontend URL to `FRONTEND_URL` in `.env`.

### Ponder Sync Failed

**Error:** `Error: Failed to fetch from Ponder`

**Solution:** Ensure Ponder indexer is running at `PONDER_URL`.

## Logs

The server logs important events for debugging:

```
Server running on port 3300 in development mode.
Database connected successfully
Auto-sync started from Ponder
Synced 15 campaigns, 42 donations, 8 badges
```

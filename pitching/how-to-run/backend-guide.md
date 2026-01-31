# 2. Backend Guide

This guide provides comprehensive instructions for setting up and running the CrowdFUNding backend server, including its architecture and key components.

## Overview

The backend is an **Express.js** server built with TypeScript that serves as the **central API layer** for the CrowdFUNding platform. It acts as a **single source of truth** for the frontend, handling authentication, caching blockchain data, and storing off-chain information in PostgreSQL.

**Key Responsibilities:**

- User authentication (Google OAuth, wallet-based login)
- PostgreSQL database for off-chain data and blockchain data caching
- Dual synchronization system with Ponder indexer (Webhook + Auto-Sync)
- REST API as the **only data source** for the frontend
- Achievement and badge management
- Share link generation for social features

**Architecture Benefits:**

- **Single Data Source:** Frontend only queries backend API, never directly to blockchain or Ponder
- **Easier Debugging:** All data flows through backend, making it easier to track and debug issues
- **Better Performance:** Cached data in PostgreSQL provides faster response times
- **Simplified Maintenance:** Changes to data structure only need to be updated in one place
- **Resource Efficiency:** Reduces load on Ponder indexer and blockchain RPC providers

## Architecture

The backend follows a layered architecture pattern that separates concerns and improves maintainability.

```mermaid
flowchart TB
    subgraph Frontend["Frontend (Next.js)"]
        UI["User Interface"]
        APIClient["API Client"]
    end

    subgraph Backend["Backend (Express.js)"]
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
            Models["Models"]
            PonderClient["Ponder API Client"]
        end
    end

    subgraph External["External Services"]
        PostgreSQL[(PostgreSQL<br/>Supabase)]
        Ponder["Ponder Indexer<br/>(GraphQL API)"]
        Blockchain["Blockchain<br/>(Base Sepolia)"]
        Google["Google OAuth"]
    end

    subgraph Sync["Sync System"]
        Webhook["Webhook Sync<br/>(PRIMARY)<br/>Real-time"]
        AutoSync["Auto-Sync<br/>(FALLBACK)<br/>5 minutes"]
    end

    UI --> APIClient
    APIClient -->|"HTTP/REST"| Routes
    Routes --> Middleware --> Business
    Business --> Data
    Models --> PostgreSQL
    PonderClient --> Ponder
    AuthCtrl --> Google

    Blockchain -->|"Events"| Ponder
    Ponder -->|"Push (< 1s)"| Webhook
    Ponder -->|"Poll (5 min)"| AutoSync
    Webhook --> SyncCtrl
    AutoSync --> SyncCtrl
    SyncCtrl --> PostgreSQL

    style Frontend fill:#e1f5ff
    style Backend fill:#fff4e1
    style Sync fill:#e8f5e9
    style PostgreSQL fill:#f3e5f5
    style Webhook fill:#4caf50
    style AutoSync fill:#ff9800
```

**Data Flow Explanation:**

1. **Blockchain → Ponder:** Smart contract events are indexed by Ponder
2. **Ponder → Backend (Webhook - PRIMARY):** Real-time push when events occur (< 1 second)
3. **Ponder → Backend (Auto-Sync - FALLBACK):** Periodic polling every 5 minutes as backup
4. **Backend → PostgreSQL:** All data stored in centralized database
5. **Frontend → Backend → PostgreSQL:** Frontend **ONLY** queries backend API, never directly to Ponder or blockchain

### Key Architectural Decisions

The following table explains the major architectural choices and their benefits:

| Decision                 | Implementation                           | Benefit                                   |
| ------------------------ | ---------------------------------------- | ----------------------------------------- |
| **Centralized API**      | Frontend → Backend only                  | Easier debugging, single point of control |
| **Layered Architecture** | Routes → Controllers → Models            | Separation of concerns, testability       |
| **PostgreSQL Caching**   | Store indexed data locally               | Fast queries, reduced Ponder load         |
| **Dual Sync Strategy**   | Webhook (primary) + Auto-Sync (fallback) | Real-time updates + reliability guarantee |
| **Webhook-First Sync**   | Event-driven push from Ponder            | Real-time data (< 1 second latency)       |
| **Auto-Sync Fallback**   | 5-minute polling from Ponder             | Catches missed events, recovery mechanism |
| **Passport.js Auth**     | Google OAuth + JWT                       | Flexible authentication strategies        |

**Why Frontend Only Queries Backend:**

The architecture ensures that the frontend **never directly queries** Ponder indexer or blockchain. All data flows through the backend API. This provides several advantages:

- **Centralized Data Control:** One source of truth for all application data
- **Easier Debugging:** All requests logged and traceable in one place
- **Better Error Handling:** Backend can handle Ponder/blockchain failures gracefully
- **Faster Response Times:** PostgreSQL queries are faster than GraphQL/RPC calls
- **Reduced External Dependencies:** Frontend doesn't need blockchain provider URLs
- **Easier Maintenance:** API contract changes only affect backend, not frontend
- **Better Caching:** Backend can implement intelligent caching strategies
- **Security:** Sensitive blockchain operations isolated in backend

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

| Table          | On-chain Data                    | Off-chain Data                  |
| -------------- | -------------------------------- | ------------------------------- |
| `vaults`       | id, name, balance, target, owner | description, imageUrl, category |
| `users`        | wallet_address                   | email, name, preferences        |
| `achievements` | token_id (NFT)                   | badge_type, earned_at           |
| `shares`       | -                                | short_code, click_count         |

## Environment Setup

Create a `.env` file in the project root with the following configuration:

```env
# ============================
# Server Configuration
# ============================
NODE_ENV=development
PORT=3300

# ============================
# Frontend URL (for CORS)
# ============================
FRONTEND_URL=http://localhost:3000

# Backend URL (for Ponder webhook)
BACKEND_URL=http://localhost:3300

# ============================
# Blockchain Configuration
# ============================
RPC_URL=https://sepolia.base.org
PRIVATE_KEY=your-private-key-here

# ============================
# Google OAuth
# ============================
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3300/auth/google/callback

# ============================
# Authentication
# ============================
SESSION_SECRET=your-super-secret-session-key
JWT_SECRET=your-jwt-secret-key

# ============================
# Ponder Indexer
# ============================
PONDER_URL=http://localhost:42069

# ============================
# Midtrans (QRIS Payment)
# ============================
MIDTRANS_CLIENT_KEY=your-midtrans-client-key
MIDTRANS_SERVER_KEY=your-midtrans-server-key
MIDTRANS_AUTH=your-midtrans-auth-token

# ============================
# Database (PostgreSQL)
# ============================
POSTGRESQL_URL=postgresql://username:password@host:port/database

# ============================
# Sync Configuration
# ============================
SYNC_INTERVAL_MS=300000
PONDER_SYNC_API_KEY=your-sync-api-key
```

### How to Get Environment Keys

The following table provides instructions for obtaining each required key:

| Variable               | How to Obtain                                                                           |
| ---------------------- | --------------------------------------------------------------------------------------- |
| `POSTGRESQL_URL`       | Create free PostgreSQL at [Supabase](https://supabase.com) or [Neon](https://neon.tech) |
| `GOOGLE_CLIENT_ID`     | [Google Cloud Console](https://console.cloud.google.com) → APIs → Credentials           |
| `GOOGLE_CLIENT_SECRET` | Same as GOOGLE_CLIENT_ID, shown during credential creation                              |
| `RPC_URL`              | [Alchemy](https://alchemy.com) or [Infura](https://infura.io) → Create Base Sepolia app |
| `PRIVATE_KEY`          | Export from MetaMask (for badge minting)                                                |
| `MIDTRANS_CLIENT_KEY`  | [Midtrans Dashboard](https://dashboard.midtrans.com) → Settings → Access Keys           |
| `MIDTRANS_SERVER_KEY`  | Same location as MIDTRANS_CLIENT_KEY                                                    |
| `PONDER_SYNC_API_KEY`  | Generate a secure random string for webhook authentication                              |
| `SYNC_INTERVAL_MS`     | Default: 300000 (5 minutes), adjust based on your needs                                 |

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

## Data Synchronization System

The backend uses a **dual synchronization strategy** to ensure data consistency between blockchain events and the PostgreSQL database.

### Sync Architecture Overview

```mermaid
sequenceDiagram
    participant Blockchain as Base Sepolia
    participant Ponder as Ponder Indexer
    participant Webhook as Webhook Sync
    participant AutoSync as Auto-Sync Service
    participant Backend as Backend API
    participant DB as PostgreSQL

    Note over Blockchain,DB: PRIMARY PATH (Real-time)
    Blockchain->>Ponder: Event emitted
    Ponder->>Ponder: Index to SQLite
    Ponder->>Webhook: Push event data
    Webhook->>Backend: POST /api/sync/*
    Backend->>DB: Insert/Update

    Note over Blockchain,DB: FALLBACK PATH (Every 5 minutes)
    AutoSync->>Ponder: Query GraphQL
    Ponder-->>AutoSync: Return all data
    AutoSync->>DB: Upsert data
```

### 1. Webhook Sync (PRIMARY)

**File:** `indexer/src/utils/syncBackend.ts`

The webhook system provides **real-time synchronization** from Ponder to the backend:

- **Trigger:** Event-driven (every blockchain event)
- **Latency:** < 1 second
- **Data:** Only new/updated records
- **Efficiency:** High (minimal data transfer)
- **Use Case:** Normal operation, real-time updates

**How it works:**

1. Blockchain event occurs (e.g., `CampaignCreated`, `Donated`)
2. Ponder indexes the event to SQLite
3. Ponder immediately pushes data to backend via HTTP POST
4. Backend receives and stores data in PostgreSQL
5. Frontend queries backend API for updated data

**Configuration:**

```typescript
// indexer/src/utils/syncBackend.ts
const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:3300";
const API_KEY = process.env.PONDER_SYNC_API_KEY;
```

### 2. Auto-Sync Service (FALLBACK)

**File:** `be/services/autoSync.ts`

The auto-sync service provides **periodic synchronization** as a fallback mechanism:

- **Trigger:** Time-based (every 5 minutes)
- **Latency:** Up to 5 minutes
- **Data:** All records (up to 1000 per entity)
- **Efficiency:** Medium (queries all data)
- **Use Case:** Recovery, missed events, initial load, consistency check

**Why Auto-Sync is Needed (Preventive Measure):**

While webhooks handle 99% of syncs in real-time, auto-sync serves as a **safety net** for edge cases:

1. **Network Failures:** If webhook fails to reach backend (network issues, backend downtime)
2. **Missed Events:** If Ponder restarts and misses pushing some events
3. **Initial Data Load:** When backend starts for the first time
4. **Data Consistency Check:** Periodic verification that all data is synced
5. **Recovery from Errors:** Automatically fixes sync gaps without manual intervention

**Resource Efficiency:**

The 5-minute interval is chosen to balance reliability and resource usage:

- **Time Efficient:** 5 minutes is frequent enough to catch issues quickly
- **Resource Efficient:** 12 queries/hour vs 10-second interval would be 360 queries/hour (30x reduction)
- **Network Efficient:** Only runs when webhook might have failed
- **Cost Efficient:** Reduces load on Ponder GraphQL API

**How it works:**

```typescript
// services/autoSync.ts
const SYNC_INTERVAL_MS = parseInt(process.env.SYNC_INTERVAL_MS || "300000"); // 5 minutes

export function startAutoSync() {
  // Initial sync on startup (loads historical data)
  syncFromPonder();

  // Periodic sync every 5 minutes (fallback mechanism)
  setInterval(syncFromPonder, SYNC_INTERVAL_MS);
}
```

The sync service is started automatically when the server boots and runs in the background.

### Comparison: Webhook vs Auto-Sync

| Feature            | Webhook (Primary)          | Auto-Sync (Fallback)    |
| ------------------ | -------------------------- | ----------------------- |
| **Trigger**        | Event-driven               | Time-based (5 min)      |
| **Latency**        | < 1 second                 | Up to 5 minutes         |
| **Data Volume**    | Only changes               | All data (1000 items)   |
| **Efficiency**     | Very High                  | Medium                  |
| **Reliability**    | Medium (network dependent) | High (retries possible) |
| **Use Case**       | Normal operation           | Recovery & backup       |
| **Resource Usage** | Very Low                   | Medium                  |
| **Success Rate**   | ~99%                       | 100% (eventually)       |

**Recommended Configuration:**

For **development**:

```env
SYNC_INTERVAL_MS=300000  # 5 minutes
```

For **production**:

```env
SYNC_INTERVAL_MS=300000  # Keep at 5 minutes
# OR
SYNC_INTERVAL_MS=600000  # 10 minutes if webhook is very reliable
```

**Note:** Never set below 60000 (1 minute) to avoid excessive load on Ponder.

## API Endpoints

The backend exposes REST endpoints organized by feature. All routes are prefixed with `/crowdfunding`.

### Authentication Endpoints

These endpoints handle user login and session management:

| Method | Endpoint        | Description          | Auth |
| ------ | --------------- | -------------------- | ---- |
| POST   | `/google-login` | Google OAuth login   | No   |
| POST   | `/wallet-login` | Wallet-based login   | No   |
| GET    | `/auth/status`  | Check session status | Yes  |
| POST   | `/auth/logout`  | End session          | Yes  |

### Campaign (Vault) Endpoints

These endpoints manage crowdfunding campaigns:

| Method | Endpoint               | Description         | Auth |
| ------ | ---------------------- | ------------------- | ---- |
| GET    | `/vaults`              | List all campaigns  | No   |
| GET    | `/vault/:id`           | Get single campaign | No   |
| POST   | `/vault/create`        | Create campaign     | Yes  |
| PATCH  | `/vault/:id`           | Update campaign     | Yes  |
| GET    | `/vaults/statistics`   | Platform stats      | No   |
| GET    | `/vault/:id/donations` | Campaign donations  | No   |

### Achievement Endpoints

These endpoints manage user achievements and badges:

| Method | Endpoint                     | Description              | Auth |
| ------ | ---------------------------- | ------------------------ | ---- |
| GET    | `/achievements`              | Get user achievements    | Yes  |
| GET    | `/achievements/:id`          | Get specific achievement | Yes  |
| POST   | `/achievements`              | Create achievement       | Yes  |
| POST   | `/achievements/:id/mint`     | Mint as NFT              | Yes  |
| GET    | `/achievements/campaign/:id` | Campaign achievements    | No   |

### Share Endpoints

These endpoints handle social sharing features:

| Method | Endpoint                  | Description          | Auth |
| ------ | ------------------------- | -------------------- | ---- |
| POST   | `/share/generate`         | Create share link    | Yes  |
| GET    | `/share/:shortCode`       | Redirect to campaign | No   |
| GET    | `/share/:shortCode/qr`    | Generate QR code     | No   |
| GET    | `/share/:shortCode/stats` | Link statistics      | No   |

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

For container-based deployment:

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
🚀 Starting auto-sync scheduler (FALLBACK mode)
   Interval: 300s (5 minutes)
   Primary sync: Webhooks from Ponder (real-time)
📥 Running initial sync on startup...
✅ Auto-sync completed: { campaigns: 15, donations: 42, badges: 8, withdrawals: 3 }
```

**Log Levels:**.

- `🔧` Configuration information
- `⏱️` Timing and interval information
- `ℹ️` General information
- `🚀` Service startup
- `📥` Data sync operations
- `🔄` Sync in progress
- `✅` Success
- `❌` Errors
- `⏳` Waiting/Skipping

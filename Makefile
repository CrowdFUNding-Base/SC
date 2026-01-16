# 1. Load environment variables from .env
-include .env

# 2. Configuration Variables
# You can overwrite these in your .env file
DEPLOY_SCRIPT := ./script/Deployer.s.sol:Deployer
BASE_RPC_URL ?= "https://base-sepolia.g.alchemy.com/"
LOCAL_RPC_URL ?= http://127.0.0.1:8545
ETHERSCAN_API_KEY ?= ""

# Default Anvil Private Key (Account #0) - safe for local testing only
LOCAL_PRIVATE_KEY ?= 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
PRIVATE_KEY ?= ""

# 3. Commands

.PHONY: local-dry local-deploy base-dry base-deploy

# --- Local (Anvil) ---
# Simulates the deployment script in a local environment
local-dry:
	forge script $(DEPLOY_SCRIPT) \
		--rpc-url $(LOCAL_RPC_URL)

# Broadcasts the deployment to your local Anvil node
# Requires 'anvil' running in a separate terminal
local-deploy:
	forge script $(DEPLOY_SCRIPT) \
		--rpc-url $(LOCAL_RPC_URL) \
		--private-key $(LOCAL_PRIVATE_KEY) \
		--broadcast

# --- Base (Mainnet) ---
# Simulates the deployment against Base Mainnet (forking/dry-run)
base-dry:
	forge script $(DEPLOY_SCRIPT) \
		--rpc-url $(BASE_RPC_URL)

# Broadcasts the deployment to Base Mainnet
# Requires 'PRIVATE_KEY' to be set in your .env file
base-deploy:
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "Error: PRIVATE_KEY is not set in .env"; exit 1; fi
	forge script $(DEPLOY_SCRIPT) \
		--rpc-url $(BASE_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast

base-deploy-verify:
	forge script $(DEPLOY_SCRIPT) \
		--rpc-url $(BASE_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)
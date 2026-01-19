// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {USDC} from "../src/MockToken/MockUSDC.sol";
import {Campaign} from "../src/Campaign.sol";
import {Badge} from "../src/Badge.sol";
import {MockSwap} from "../src/MockSwap.sol";

contract Deployer is Script {
    IDRX mockIdrx;
    USDC mockUsdc;
    Campaign campaign;
    MockSwap swap;
    Badge badge;

    // Exchange rates (per 1 ETH = 10^18 wei)
    // 1 ETH = 3300 USDC (6 decimals) = 3300 * 10^6 = 3_300_000_000
    uint256 constant ETH_TO_USDC = 3_300_000_000;
    // 1 ETH = 54,000,000 IDRX (2 decimals) = 54_000_000 * 10^2 = 5_400_000_000
    uint256 constant ETH_TO_IDRX = 5_400_000_000;

    function run() public {
        vm.startBroadcast();
        deployMockToken();
        deploySwap();
        deployContract();
        deployBadge();
        vm.stopBroadcast();
    }

    // deploy mock token
    function deployMockToken() public {
        mockIdrx = new IDRX();
        mockUsdc = new USDC();
        console.log("Mock IDRX deployed at:", address(mockIdrx));
        console.log("Mock USDC deployed at:", address(mockUsdc));
    }

    // deploy swap contract
    function deploySwap() public {
        swap = new MockSwap();

        // Add tokens with ETH rates (1 ETH = X tokens in smallest unit)
        swap.addToken(address(mockIdrx), ETH_TO_IDRX, mockIdrx.decimals());
        swap.addToken(address(mockUsdc), ETH_TO_USDC, mockUsdc.decimals());

        // Mint liquidity to swap contract
        mockIdrx.mint(address(swap), 10_000_000_000 * 10 ** mockIdrx.decimals());
        mockUsdc.mint(address(swap), 10_000_000 * 10 ** mockUsdc.decimals());

        console.log("Swap deployed at:", address(swap));
    }

    // deploy contract
    function deployContract() public {
        campaign = new Campaign(address(swap), address(mockIdrx));
        console.log("Contract deployed at:", address(campaign));
    }

    // deploy badge
    function deployBadge() public {
        badge = new Badge();
        console.log("Badge deployed at:", address(badge));
    }
}

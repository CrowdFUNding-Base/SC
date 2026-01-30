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

    // Exchange rates (per 1 Base Native Token = 10^18 wei)
    // 1 Base = 0.16 USDC (6 decimals) = 0.16 * 10^6 = 160_000
    uint256 constant BASE_TO_USDC = 160_000;
    // 1 Base = 2684 IDRX (2 decimals) = 2684 * 10^2 = 268_400

    uint256 constant BASE_TO_IDRX = 26_840_000_000;

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

        // Add tokens with Base rates (1 Base = X tokens in smallest unit)
        swap.addToken(address(mockIdrx), BASE_TO_IDRX, mockIdrx.decimals());
        swap.addToken(address(mockUsdc), BASE_TO_USDC, mockUsdc.decimals());

        // Mint liquidity to swap contract
        mockIdrx.mint(address(swap), 10_000_000_000 * 10 ** mockIdrx.decimals());
        mockUsdc.mint(address(swap), 10_000_000 * 10 ** mockUsdc.decimals());

        console.log("Swap deployed at:", address(swap));
    }

    // deploy contract
    function deployContract() public {
        campaign = new Campaign(payable(address(swap)), address(mockIdrx));
        console.log("Contract deployed at:", address(campaign));
    }

    // deploy badge
    function deployBadge() public {
        badge = new Badge();
        console.log("Badge deployed at:", address(badge));
    }
}

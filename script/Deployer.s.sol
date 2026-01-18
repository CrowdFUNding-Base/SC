// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {USDC} from "../src/MockToken/MockUSDC.sol";
import {Campaign} from "../src/Campaign.sol";
import {Badge} from "../src/Badge.sol";

contract Deployer is Script{
    IDRX mockIdrx;
    USDC mockUsdc;
    Campaign campaign;
    Badge badge;
    function run() public {
        vm.startBroadcast();
        // deployMockToken();
        // deployContract();
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

    // deploy contract
    function deployContract() public {
        campaign = new Campaign();
        console.log("Contract deployed at:", address(campaign));
    }

    // deploy badge
    function deployBadge() public {
        badge = new Badge();
        console.log("Badge deployed at:", address(badge));
    }
}
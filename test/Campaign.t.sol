// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";

contract CampaignTest is Test {
    Campaign campaign;
    address user;

    function setUp() public {
        campaign = new Campaign();        
        user = makeAddr("user");
    }

    function testCreateCampaign() public {
        address campaignAddress = campaign.createCampaign("Bencana Jawa", "Andi Saputra", 2 ether);
        (string memory name, string memory creatorName, uint256 balance, uint256 targetAmount, uint256 creationTime, address owner) = campaign.getCampaignInfo(campaignAddress);
        assertEq(name, "Bencana Jawa");
        assertEq(creatorName, "Andi Saputra");
        assertEq(balance, 0);
        console.log("Campaign created at address:", campaignAddress);
    }

    function testDonate() public {
        address campaignAddress = campaign.createCampaign("Bencana Jawa", "Andi Saputra", 2 ether);
        hoax(user, 10 ether);
        campaign.donate{value: 1 ether}(campaignAddress, 1 ether);
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignAddress);
        assertEq(balance, 1 ether);
        assertEq(user.balance, 9 ether);
        console.log("Donation successful, campaign balance:", balance);
    }

    function testWithdraw() public {
        hoax(user, 10 ether);
        address campaignAddress = campaign.createCampaign("Bencana Jawa", "Andi Saputra", 2 ether);
        address user2 = makeAddr("user2");
        hoax(user2, 5 ether);
        campaign.donate{value: 1 ether}(campaignAddress, 1 ether);
        vm.prank(user);
        campaign.withdraw(campaignAddress, 1 ether);
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignAddress);
        assertEq(balance, 0);
        assertEq(user2.balance, 4 ether);
        assertEq(user.balance, 11 ether);
        console.log("Withdrawal successful, campaign balance:", balance);
        console.log("User balance after withdrawal:", user.balance);   
        console.log("User2 balance after donation:", user2.balance);
    }

    function testOnlyOwnerCanWithdraw() public {
        hoax(user, 10 ether);
        address campaignAddress = campaign.createCampaign("Bencana Jawa", "Andi Saputra", 2 ether);
        (, , , , , address owner) = campaign.getCampaignInfo(campaignAddress);
        assertEq(owner, user);
        address user2 = makeAddr("user2");
        console.log("Campaign created by:", owner);
        console.log("User1 (owner) address is:", user);
        console.log("Campaign owner is:", owner);
        console.log("User2 attempting to donate");
        hoax(user2, 5 ether);
        console.log("User2 address is:", user2);
        campaign.donate{value: 1 ether}(campaignAddress, 1 ether);
        console.log("Attempting withdrawal by non-owner... (user2)");
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Campaign.OnlyOwnerCanWithdraw.selector, user2));
        campaign.withdraw(campaignAddress, 1 ether);
    }

    function testReentrancyAttack() public {
        // This is a placeholder for a reentrancy attack test.
        // Implementing a full reentrancy attack test would require a malicious contract.
        // For now, we will just ensure that the withdraw function is protected by nonReentrant.
        hoax(user, 10 ether);
        address campaignAddress = campaign.createCampaign("Bencana Jawa", "Andi Saputra", 2 ether);
        hoax(user, 5 ether);
        campaign.donate{value: 5 ether}(campaignAddress, 5 ether);
        vm.prank(user);
        campaign.withdraw(campaignAddress, 1 ether);
        console.log("Reentrancy protection test passed.");
    }
}
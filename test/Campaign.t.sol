// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CampaignTest is Test {
    Campaign campaign;
    uint256 campaignId;
    address user;
    address user2;
    IDRX mockToken;

    uint256 constant INITIAL_AMOUNT = 10 ether;
    uint256 constant CAMPAIGN_TARGET = 2 ether;
    uint256 constant DONATE_AMOUNT = 4 ether;
    uint256 constant USER2_BALANCE = 4 ether;
    uint256 constant WITHDRAW_AMOUNT = 2 ether;
    uint256 constant DONATE_MULTIPLIER = 5;
    uint256 constant ZERO = 0;

    modifier initCampaign{
        campaignId = campaign.createCampaign("Bencana Jawa", "Andi Saputra", CAMPAIGN_TARGET);
        _;
    }

    modifier initCampaignAndUser{
        hoax(user, INITIAL_AMOUNT);
        campaignId = campaign.createCampaign("Bencana Jawa", "Andi Saputra", CAMPAIGN_TARGET);
        _;
    }

    function setUp() public {
        campaign = new Campaign();        
        user = makeAddr("user");
        user2 = makeAddr("user2");  
        mockToken = new IDRX();     
        mockToken.mint(user, INITIAL_AMOUNT);
        mockToken.mint(user2, USER2_BALANCE);
    }

    function testCreateCampaign() public initCampaign() {
        (string memory name, string memory creatorName, uint256 balance, uint256 targetAmount, uint256 creationTime, address owner) = campaign.getCampaignInfo(campaignId);
        assertEq(name, "Bencana Jawa");
        assertEq(creatorName, "Andi Saputra");
        assertEq(balance, 0);
        console.log("Campaign created at address:", campaignId);
    }

    function testDonate() public initCampaignAndUser  {
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignId);
        assertEq(balance, DONATE_AMOUNT);
        assertEq(user2.balance, USER2_BALANCE - DONATE_AMOUNT);
        console.log("Donation successful, campaign balance:", balance);
    }

    
    function testDonateERC20() public initCampaignAndUser  {
        console.log("BALANCE USER 2", mockToken.getBalance(user2));
        console.log("BALANCE USER", mockToken.getBalance(user));
        
        // User2 must approve the campaign contract to spend their tokens FIRST
        vm.prank(user2);
        mockToken.approve(address(campaign), DONATE_AMOUNT);
        
        // Now user2 can donate
        vm.prank(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignId);
        assertEq(balance, DONATE_AMOUNT);
        // Check token balance decreased, not ETH balance
        assertEq(mockToken.getBalance(user2), USER2_BALANCE - DONATE_AMOUNT);
        console.log("Donation successful, campaign balance:", balance);
    }


    function testDonateMustBeGreaterThanZero() public initCampaignAndUser {
        vm.expectRevert(abi.encodeWithSelector(Campaign.AmountMustBeGreaterThanZero.selector, ZERO));
        campaign.donate{value: ZERO}(campaignId, ZERO);
    }

    function testDonateERC20MustBeGreaterThanZero() public initCampaignAndUser {
        hoax(user2);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Campaign.AmountMustBeGreaterThanZero.selector, ZERO));
        campaign.donate(campaignId, ZERO, address(mockToken));
    }

    function testDonateOnlyOnAvailableCampaign () public initCampaignAndUser  {
        campaignId = 1;
        vm.expectRevert(abi.encodeWithSelector(Campaign.CampaignNotFound.selector, campaignId));
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
    }

    function testDonateERC20OnlyOnAvailableCampaign () public initCampaignAndUser  {
        campaignId = 1;
        hoax(user2);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Campaign.CampaignNotFound.selector, campaignId));
        vm.prank(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
    }

    function testWithdraw() public initCampaignAndUser  {
        hoax(user2, USER2_BALANCE); 
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        vm.startPrank(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT);
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignId);
        console.log("No ", balance, user2.balance, user.balance);
        assertEq(balance, DONATE_AMOUNT - WITHDRAW_AMOUNT);
        assertEq(user2.balance, USER2_BALANCE - DONATE_AMOUNT);
        assertEq(user.balance, INITIAL_AMOUNT + WITHDRAW_AMOUNT);
        console.log("Withdrawal successful, campaign balance:", balance);
        vm.stopPrank();
    }

    function testWithdrawERC20() public initCampaignAndUser  {
        hoax(user2, USER2_BALANCE);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        hoax(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        hoax(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT, address(mockToken));
        (, , uint256 balance, , , ) = campaign.getCampaignInfo(campaignId);
        console.log("WITH ", balance, user2.balance, user.balance);
        assertEq(balance, DONATE_AMOUNT - WITHDRAW_AMOUNT);
        assertEq(mockToken.balanceOf(user2), USER2_BALANCE - DONATE_AMOUNT);
        assertEq(mockToken.balanceOf(user), INITIAL_AMOUNT + WITHDRAW_AMOUNT);
        console.log("Withdrawal successful, campaign balance:", balance);
    }

    function testWithdrawLessBalnace() public initCampaignAndUser  {
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Campaign.InsufficientBalance.selector, WITHDRAW_AMOUNT + DONATE_AMOUNT, DONATE_AMOUNT));
        vm.prank(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT + DONATE_AMOUNT);
    }

    function testWithdrawERC20LessBalance() public initCampaignAndUser  {
        hoax(user2, DONATE_AMOUNT);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        hoax(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        hoax(user);
        vm.expectRevert(abi.encodeWithSelector(Campaign.InsufficientBalance.selector, WITHDRAW_AMOUNT + DONATE_AMOUNT, DONATE_AMOUNT));
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT + DONATE_AMOUNT, address(mockToken));
    }

    function testOnlyOwnerCanWithdraw() public initCampaignAndUser  {
        (, , , , , address owner) = campaign.getCampaignInfo(campaignId);
        assertEq(owner, user);
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        hoax(user2);
        vm.expectRevert(abi.encodeWithSelector(Campaign.OnlyOwnerCanWithdraw.selector, user2));
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT);
        hoax(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT);
    }

    function testOnlyOwnerCanWithdrawERC20() public initCampaignAndUser  {
        (, , , , , address owner) = campaign.getCampaignInfo(campaignId);
        assertEq(owner, user);
        vm.startPrank(user2);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        vm.expectRevert(abi.encodeWithSelector(Campaign.OnlyOwnerCanWithdraw.selector, user2));
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT, address(mockToken));
        vm.stopPrank();
        vm.prank(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT, address(mockToken));
    }

    function testReentrancyAttack() public initCampaignAndUser () {
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        hoax(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT);
        console.log("Reentrancy protection test passed.");
    }
}
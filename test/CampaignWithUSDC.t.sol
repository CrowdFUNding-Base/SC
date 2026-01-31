// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {USDC} from "../src/MockToken/MockUSDC.sol";
import {MockSwap} from "../src/MockSwap.sol";

/**
 * @title CampaignWithUSDCTest
 * @notice Tests donation with USDC that gets swapped to IDRX, and withdrawal in IDRX
 */
contract CampaignWithUSDCTest is Test {
    Campaign campaign;
    uint256 campaignId;
    address user; // Campaign owner
    address donor; // USDC donor
    MockSwap mockSwap;
    IDRX idrxToken;
    USDC usdcToken;

    // USDC amounts (6 decimals)
    uint256 constant USDC_INITIAL_AMOUNT = 10_000 * 10 ** 6; // 10,000 USDC
    uint256 constant USDC_DONATE_AMOUNT = 100 * 10 ** 6; // 100 USDC

    // IDRX amounts (2 decimals)
    uint256 constant IDRX_INITIAL_AMOUNT = 1_000_000_000 * 10 ** 2; // 1B IDRX for liquidity

    // Target in storage token (IDRX)
    uint256 constant CAMPAIGN_TARGET = 1_000_000 * 10 ** 2; // 1M IDRX

    // Exchange rates (per 1 Base Native Token = 10^18 wei)
    // 1 Base = 0.16 USDC (6 decimals) = 0.16 * 10^6 = 160_000
    uint256 constant BASE_TO_USDC = 160_000;
    // 1 Base = 2684 IDRX (2 decimals)
    // For correct token-to-token swap math in MockSwap, scaled by 100
    // This gives: 1 USDC ≈ 16,775 IDRX (in human terms)
    // For 100 USDC → 1,677,500 IDRX = 167,750,000 raw units (2 decimals)
    uint256 constant BASE_TO_IDRX = 2_684_000_000;

    modifier initCampaign() {
        vm.prank(user);
        campaignId = campaign.createCampaign("Bencana Jawa", "Andi Saputra", CAMPAIGN_TARGET);
        _;
    }

    function setUp() public {
        // Deploy mock tokens
        idrxToken = new IDRX();
        usdcToken = new USDC();

        // Deploy MockSwap
        mockSwap = new MockSwap();

        // Add IDRX and USDC to MockSwap with Base Native Token rates
        mockSwap.addToken(address(usdcToken), BASE_TO_USDC, usdcToken.decimals());
        mockSwap.addToken(address(idrxToken), BASE_TO_IDRX, idrxToken.decimals());

        // Mint IDRX liquidity to MockSwap for swaps to work
        idrxToken.mint(address(mockSwap), IDRX_INITIAL_AMOUNT);
        // Mint USDC liquidity to MockSwap for swaps to work
        usdcToken.mint(address(mockSwap), USDC_INITIAL_AMOUNT);

        // Deploy Campaign with MockSwap and IDRX as storage token
        campaign = new Campaign(payable(address(mockSwap)), address(idrxToken));

        // Setup users
        user = makeAddr("campaignOwner");
        donor = makeAddr("usdcDonor");

        // Mint USDC to donor
        usdcToken.mint(donor, USDC_INITIAL_AMOUNT);
    }

    /**
     * @notice Test donating with USDC and verifying it gets swapped to IDRX
     */
    function testDonateWithUSDC() public initCampaign {
        console.log("=== Test: Donate with USDC ===");
        console.log("Donor USDC balance before:", usdcToken.balanceOf(donor));

        // Calculate expected IDRX amount from swap
        // 100 USDC -> ETH -> IDRX
        // 100 USDC = 100 * 10^6 = 100_000_000 (in smallest unit)
        // Normalize to 18 decimals: 100_000_000 * 10^12 = 10^20
        // ETH equivalent: (10^20 * 10^18) / 3_000_000_000 = 3.33... * 10^28
        // IDRX normalized: 3.33... * 10^28 * 4_800_000_000 / 10^18
        // Denormalize: result / 10^16
        uint256 expectedIdrx = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);
        console.log("Expected IDRX from swap:", expectedIdrx);

        // Donor approves and donates USDC
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), USDC_DONATE_AMOUNT);
        campaign.donate(campaignId, USDC_DONATE_AMOUNT, address(usdcToken));
        vm.stopPrank();

        // Verify campaign balance is in IDRX
        (,, uint256 balance,,,) = campaign.getCampaignInfo(campaignId);
        console.log("Campaign balance (in IDRX):", balance);
        console.log("Donor USDC balance after:", usdcToken.balanceOf(donor));

        assertEq(balance, expectedIdrx, "Campaign balance should match swapped IDRX amount");
        assertEq(usdcToken.balanceOf(donor), USDC_INITIAL_AMOUNT - USDC_DONATE_AMOUNT, "Donor should have less USDC");
    }

    /**
     * @notice Test donating with USDC and withdrawing in IDRX
     */
    function testDonateUSDCWithdrawIDRX() public initCampaign {
        console.log("=== Test: Donate USDC, Withdraw IDRX ===");

        // Get expected IDRX amount
        uint256 expectedIdrx = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);
        console.log("Expected IDRX from 100 USDC:", expectedIdrx);

        // Donor donates USDC
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), USDC_DONATE_AMOUNT);
        campaign.donate(campaignId, USDC_DONATE_AMOUNT, address(usdcToken));
        vm.stopPrank();

        // Verify campaign has IDRX balance
        (,, uint256 balanceAfterDonation,,,) = campaign.getCampaignInfo(campaignId);
        console.log("Campaign balance after donation:", balanceAfterDonation);
        assertEq(balanceAfterDonation, expectedIdrx);

        // Owner withdraws half in IDRX
        uint256 withdrawAmount = expectedIdrx / 2;
        console.log("Withdrawing IDRX amount:", withdrawAmount);

        uint256 ownerIdrxBefore = idrxToken.balanceOf(user);
        console.log("Owner IDRX balance before withdrawal:", ownerIdrxBefore);

        vm.prank(user);
        campaign.withdraw(campaignId, withdrawAmount, address(idrxToken));

        uint256 ownerIdrxAfter = idrxToken.balanceOf(user);
        console.log("Owner IDRX balance after withdrawal:", ownerIdrxAfter);

        // Verify balances
        (,, uint256 balanceAfterWithdraw,,,) = campaign.getCampaignInfo(campaignId);
        console.log("Campaign balance after withdrawal:", balanceAfterWithdraw);

        assertEq(balanceAfterWithdraw, expectedIdrx - withdrawAmount, "Campaign balance should decrease");
        assertEq(ownerIdrxAfter, ownerIdrxBefore + withdrawAmount, "Owner should receive IDRX");
    }

    /**
     * @notice Test full withdrawal of IDRX after USDC donation
     */
    function testDonateUSDCFullWithdrawIDRX() public initCampaign {
        console.log("=== Test: Donate USDC, Full Withdraw IDRX ===");

        uint256 expectedIdrx = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);

        // Donor donates USDC
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), USDC_DONATE_AMOUNT);
        campaign.donate(campaignId, USDC_DONATE_AMOUNT, address(usdcToken));
        vm.stopPrank();

        // Owner withdraws full amount in IDRX
        vm.prank(user);
        campaign.withdraw(campaignId, expectedIdrx, address(idrxToken));

        // Verify campaign is empty
        (,, uint256 finalBalance,,,) = campaign.getCampaignInfo(campaignId);
        assertEq(finalBalance, 0, "Campaign should be empty after full withdrawal");
        assertEq(idrxToken.balanceOf(user), expectedIdrx, "Owner should have all IDRX");
    }

    /**
     * @notice Test multiple USDC donations and IDRX withdrawal
     */
    function testMultipleUSDCDonationsWithIDRXWithdraw() public initCampaign {
        console.log("=== Test: Multiple USDC Donations, IDRX Withdraw ===");

        address donor2 = makeAddr("donor2");
        usdcToken.mint(donor2, USDC_INITIAL_AMOUNT);

        uint256 donation1 = 50 * 10 ** 6; // 50 USDC
        uint256 donation2 = 75 * 10 ** 6; // 75 USDC

        uint256 expectedIdrx1 = mockSwap.getQuote(address(usdcToken), address(idrxToken), donation1);
        uint256 expectedIdrx2 = mockSwap.getQuote(address(usdcToken), address(idrxToken), donation2);

        // First donor donates
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), donation1);
        campaign.donate(campaignId, donation1, address(usdcToken));
        vm.stopPrank();

        // Second donor donates
        vm.startPrank(donor2);
        usdcToken.approve(address(campaign), donation2);
        campaign.donate(campaignId, donation2, address(usdcToken));
        vm.stopPrank();

        // Verify total balance
        (,, uint256 totalBalance,,,) = campaign.getCampaignInfo(campaignId);
        uint256 expectedTotal = expectedIdrx1 + expectedIdrx2;
        console.log("Total campaign balance:", totalBalance);
        console.log("Expected total:", expectedTotal);
        assertEq(totalBalance, expectedTotal);

        // Owner withdraws all in IDRX
        vm.prank(user);
        campaign.withdraw(campaignId, expectedTotal, address(idrxToken));

        assertEq(idrxToken.balanceOf(user), expectedTotal, "Owner should receive all IDRX");
    }

    /**
     * @notice Test that only owner can withdraw IDRX
     */
    function testOnlyOwnerCanWithdrawIDRX() public initCampaign {
        uint256 expectedIdrx = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);

        // Donor donates USDC
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), USDC_DONATE_AMOUNT);
        campaign.donate(campaignId, USDC_DONATE_AMOUNT, address(usdcToken));
        vm.stopPrank();

        // Donor tries to withdraw (should fail)
        vm.prank(donor);
        vm.expectRevert(abi.encodeWithSelector(Campaign.OnlyOwnerCanWithdraw.selector, donor));
        campaign.withdraw(campaignId, expectedIdrx / 2, address(idrxToken));

        // Owner can withdraw
        vm.prank(user);
        campaign.withdraw(campaignId, expectedIdrx / 2, address(idrxToken));
    }

    /**
     * @notice Test insufficient balance for IDRX withdrawal
     */
    function testInsufficientIDRXWithdrawal() public initCampaign {
        uint256 expectedIdrx = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);

        // Donor donates USDC
        vm.startPrank(donor);
        usdcToken.approve(address(campaign), USDC_DONATE_AMOUNT);
        campaign.donate(campaignId, USDC_DONATE_AMOUNT, address(usdcToken));
        vm.stopPrank();

        // Try to withdraw more than available
        uint256 excessAmount = expectedIdrx + 1;
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Campaign.InsufficientBalance.selector, excessAmount, expectedIdrx));
        campaign.withdraw(campaignId, excessAmount, address(idrxToken));
    }

    /**
     * @notice Test swap rate calculation
     */
    function testSwapRateCalculation() public view {
        console.log("=== Swap Rate Test ===");

        // The MockSwap uses normalized calculations with 18 decimals internally:
        // USDC: 6 decimals, rate = 160_000 (1 Base = 0.16 USDC)
        // IDRX: 2 decimals, rate = 268_400 (1 Base = 2684 IDRX)
        //
        // For 100 USDC (100 * 10^6 = 100_000_000):
        // Step 1: Normalize to 18 decimals: 100_000_000 * 10^12 = 10^20
        // Step 2: Convert to Base: (10^20 * 10^18) / 160_000 = 6.25 * 10^32
        // Step 3: Convert to IDRX normalized: 6.25 * 10^32 * 268_400 / 10^18 = 1.6775 * 10^20
        // Step 4: Denormalize to 2 decimals: result / 10^16 = 16775
        // Result: 16775 IDRX units (167.75 IDRX)

        uint256 quote = mockSwap.getQuote(address(usdcToken), address(idrxToken), USDC_DONATE_AMOUNT);
        console.log("100 USDC converts to IDRX:", quote);

        // 100 USDC / 0.16 USDC per Base * 2684 IDRX per Base = 1,677,500 IDRX
        // In smallest unit (2 decimals): 1,677,500 * 100 = 167,750,000 units
        // But MockSwap returns units directly, so: 1,677,500 units
        assertGt(quote, 0, "Quote should be greater than 0");
        assertEq(quote, 167750000, "Swap rate should match: 100 USDC = 1,677,500 IDRX");
    }
}

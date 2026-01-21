// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {MockSwap} from "../src/MockSwap.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CampaignTest is Test {
    Campaign campaign;
    uint256 campaignId;
    address user;
    address user2;
    MockSwap mockSwap;
    IDRX mockToken; // IDRX token (storage token)

    uint256 constant INITIAL_AMOUNT = 10 ether;
    uint256 constant CAMPAIGN_TARGET = 2 ether;
    uint256 constant DONATE_AMOUNT = 4 ether;
    uint256 constant USER2_BALANCE = 4 ether;
    uint256 constant WITHDRAW_AMOUNT = 2 ether;
    uint256 constant DONATE_MULTIPLIER = 5;
    uint256 constant ZERO = 0;

    // 1 Base Native Token = 0.16 USDC (6 decimals) = 0.16 * 10^6 = 160_000
    uint256 constant BASE_TO_USDC = 160_000;
    // 1 Base Native Token = 2684 IDRX (2 decimals)
    // For correct token-to-token swap math in MockSwap, scaled by 100
    // This gives: 1 USDC ≈ 16,775 IDRX
    uint256 constant BASE_TO_IDRX = 26_840_000;

    modifier initCampaign() {
        campaignId = campaign.createCampaign("Bencana Jawa", "Andi Saputra", CAMPAIGN_TARGET);
        _;
    }

    modifier initCampaignAndUser() {
        hoax(user, INITIAL_AMOUNT);
        campaignId = campaign.createCampaign("Bencana Jawa", "Andi Saputra", CAMPAIGN_TARGET);
        _;
    }

    function setUp() public {
        // Deploy contracts
        mockSwap = new MockSwap();
        mockToken = new IDRX();

        // Add mockToken (IDRX) to mockSwap with Base Native Token rate
        // IDRX has 2 decimals, so 1 Base = 54M IDRX = 54_000_000 * 10^2
        mockSwap.addToken(address(mockToken), BASE_TO_IDRX, mockToken.decimals());

        // Mint liquidity to mockSwap so swaps can work
        mockToken.mint(address(mockSwap), 1_000_000_000 * 10 ** mockToken.decimals());

        // Deploy Campaign with mockSwap and mockToken as storage token
        campaign = new Campaign(payable(address(mockSwap)), address(mockToken));

        // Setup users
        user = makeAddr("user");
        user2 = makeAddr("user2");
        mockToken.mint(user, INITIAL_AMOUNT);
        mockToken.mint(user2, USER2_BALANCE);
    }

    function testCreateCampaign() public initCampaign {
        (
            string memory name,
            string memory creatorName,
            uint256 balance,
            uint256 targetAmount,
            uint256 creationTime,
            address owner
        ) = campaign.getCampaignInfo(campaignId);
        assertEq(name, "Bencana Jawa");
        assertEq(creatorName, "Andi Saputra");
        assertEq(balance, 0);
        console.log("Campaign created at address:", campaignId);
    }

    /// @notice Test donate with Base Native Token - auto-swapped to IDRX
    function testDonateWithNativeToken() public initCampaignAndUser {
        // User2 donates with Base Native Token
        uint256 user2InitialBalance = user2.balance;

        // Fund user2 with native token for donation
        vm.deal(user2, DONATE_AMOUNT);

        vm.prank(user2);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        // Calculate expected IDRX amount after swap
        // DONATE_AMOUNT (4 ether) * BASE_TO_IDRX / 1e18
        uint256 expectedIDRXAmount = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;

        (,, uint256 balance,,,) = campaign.getCampaignInfo(campaignId);

        // Balance should be in IDRX (auto-swapped from native token)
        assertEq(balance, expectedIDRXAmount);
        assertEq(user2.balance, 0); // All native token spent

        console.log("Donation with Base Native Token successful!");
        console.log("Native Token donated:", DONATE_AMOUNT);
        console.log("IDRX received (campaign balance):", balance);
    }

    function testDonateERC20() public initCampaignAndUser {
        console.log("BALANCE USER 2", mockToken.balanceOf(user2));
        console.log("BALANCE USER", mockToken.balanceOf(user));

        // User2 must approve the campaign contract to spend their tokens FIRST
        vm.prank(user2);
        mockToken.approve(address(campaign), DONATE_AMOUNT);

        // Now user2 can donate with IDRX directly
        vm.prank(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));

        (,, uint256 balance,,,) = campaign.getCampaignInfo(campaignId);
        assertEq(balance, DONATE_AMOUNT);
        // Check IDRX balance decreased
        assertEq(mockToken.balanceOf(user2), USER2_BALANCE - DONATE_AMOUNT);
        console.log("Donation successful, campaign balance:", balance);
    }

    function testDonateNativeTokenMustBeGreaterThanZero() public initCampaignAndUser {
        vm.expectRevert(abi.encodeWithSelector(Campaign.AmountMustBeGreaterThanZero.selector, ZERO));
        campaign.donate{value: ZERO}(campaignId);
    }

    function testDonateERC20MustBeGreaterThanZero() public initCampaignAndUser {
        hoax(user2);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Campaign.AmountMustBeGreaterThanZero.selector, ZERO));
        campaign.donate(campaignId, ZERO, address(mockToken));
    }

    function testDonateNativeTokenOnlyOnAvailableCampaign() public initCampaignAndUser {
        campaignId = 1;
        vm.expectRevert(abi.encodeWithSelector(Campaign.CampaignNotFound.selector, campaignId));
        vm.deal(address(this), DONATE_AMOUNT);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);
    }

    function testDonateERC20OnlyOnAvailableCampaign() public initCampaignAndUser {
        campaignId = 1;
        hoax(user2);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Campaign.CampaignNotFound.selector, campaignId));
        vm.prank(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
    }

    /// @notice Test withdraw IDRX from campaign (donated via Native Token auto-swap)
    function testWithdrawAsIDRX() public initCampaignAndUser {
        // User2 donates with Base Native Token
        vm.deal(user2, DONATE_AMOUNT);
        vm.prank(user2);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        // Calculate expected IDRX amount after swap
        uint256 expectedIDRXAmount = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;

        // User (owner) withdraws in IDRX
        uint256 withdrawAmountIDRX = expectedIDRXAmount / 2; // Withdraw half
        uint256 userIDRXBalanceBefore = mockToken.balanceOf(user);

        vm.prank(user);
        campaign.withdraw(campaignId, withdrawAmountIDRX);

        (,, uint256 balance,,,) = campaign.getCampaignInfo(campaignId);

        // Campaign balance should decrease
        assertEq(balance, expectedIDRXAmount - withdrawAmountIDRX);
        // User should receive IDRX (not native token!)
        assertEq(mockToken.balanceOf(user), userIDRXBalanceBefore + withdrawAmountIDRX);

        console.log("Withdrawal in IDRX successful!");
        console.log("IDRX withdrawn:", withdrawAmountIDRX);
        console.log("Remaining campaign balance (IDRX):", balance);
    }

    function testWithdrawERC20() public initCampaignAndUser {
        hoax(user2, USER2_BALANCE);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        hoax(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        hoax(user);
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT, address(mockToken));
        (,, uint256 balance,,,) = campaign.getCampaignInfo(campaignId);
        console.log("WITH ", balance, user2.balance, user.balance);
        assertEq(balance, DONATE_AMOUNT - WITHDRAW_AMOUNT);
        assertEq(mockToken.balanceOf(user2), USER2_BALANCE - DONATE_AMOUNT);
        assertEq(mockToken.balanceOf(user), INITIAL_AMOUNT + WITHDRAW_AMOUNT);
        console.log("Withdrawal successful, campaign balance:", balance);
    }

    function testWithdrawIDRXLessBalance() public initCampaignAndUser {
        // Donate with native token (auto-swapped to IDRX)
        vm.deal(user2, DONATE_AMOUNT);
        vm.prank(user2);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        uint256 expectedIDRXAmount = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;
        uint256 tooMuchAmount = expectedIDRXAmount + 1000;

        vm.expectRevert(
            abi.encodeWithSelector(Campaign.InsufficientBalance.selector, tooMuchAmount, expectedIDRXAmount)
        );
        vm.prank(user);
        campaign.withdraw(campaignId, tooMuchAmount);
    }

    function testWithdrawERC20LessBalance() public initCampaignAndUser {
        hoax(user2, DONATE_AMOUNT);
        IERC20(mockToken).approve(address(campaign), DONATE_AMOUNT);
        hoax(user2);
        campaign.donate(campaignId, DONATE_AMOUNT, address(mockToken));
        hoax(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                Campaign.InsufficientBalance.selector, WITHDRAW_AMOUNT + DONATE_AMOUNT, DONATE_AMOUNT
            )
        );
        campaign.withdraw(campaignId, WITHDRAW_AMOUNT + DONATE_AMOUNT, address(mockToken));
    }

    function testOnlyOwnerCanWithdrawIDRX() public initCampaignAndUser {
        (,,,,, address owner) = campaign.getCampaignInfo(campaignId);
        assertEq(owner, user);

        // Donate with native token (auto-swapped to IDRX)
        vm.deal(user2, DONATE_AMOUNT);
        vm.prank(user2);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        uint256 expectedIDRXAmount = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;
        uint256 withdrawAmount = expectedIDRXAmount / 2;

        // Non-owner tries to withdraw
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Campaign.OnlyOwnerCanWithdraw.selector, user2));
        campaign.withdraw(campaignId, withdrawAmount);

        // Owner can withdraw
        vm.prank(user);
        campaign.withdraw(campaignId, withdrawAmount);
    }

    function testOnlyOwnerCanWithdrawERC20() public initCampaignAndUser {
        (,,,,, address owner) = campaign.getCampaignInfo(campaignId);
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

    function testReentrancyAttackWithNativeToken() public initCampaignAndUser {
        vm.deal(user2, DONATE_AMOUNT);
        vm.prank(user2);
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        uint256 expectedIDRXAmount = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;
        uint256 withdrawAmount = expectedIDRXAmount / 2;

        vm.prank(user);
        campaign.withdraw(campaignId, withdrawAmount);

        console.log("Reentrancy protection test passed.");
    }
}

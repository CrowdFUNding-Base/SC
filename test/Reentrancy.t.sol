// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockSwap} from "../src/MockSwap.sol";

contract ReentrancyAttacker {
    Campaign public campaign;
    uint256 public _campaignId;
    bool public reentered;
    address public _tokenIn = address(0);

    constructor(address _campaign) {
        campaign = Campaign(_campaign);
    }

    function createMyCampaign(string memory name, string memory creator, uint256 target, address tokenIn)
        external
        returns (uint256)
    {
        console.log("Creating attacker's campaign... using contract", address(campaign));
        uint256 id = campaign.createCampaign(name, creator, target);
        console.log("Attacker's campaign created at:", id);
        _campaignId = id;
        _tokenIn = tokenIn;
        return id;
    }

    function attack(uint256 amount) external {
        // call withdraw from this contract (msg.sender inside Campaign will be this contract)
        console.log("Attacker contract attacking campaign at:", _campaignId);
        if (_tokenIn != address(0)) {
            console.log(
                "Starting attack. Attacker balance:",
                IERC20(_tokenIn).balanceOf(address(this)),
                " Contract balance",
                IERC20(_tokenIn).balanceOf(address(campaign))
            );
            IERC20(_tokenIn).approve(address(campaign), amount);
            campaign.withdraw(_campaignId, amount, _tokenIn);
            console.log(
                "Attack finished. Attacker balance:",
                IERC20(_tokenIn).balanceOf(address(this)),
                " Contract balance",
                IERC20(_tokenIn).balanceOf(address(campaign))
            );
        } else {
            console.log(
                "Starting attack. Attacker balance:",
                address(this).balance,
                " Contract balance",
                address(campaign).balance
            );
            campaign.withdraw(_campaignId, amount);
            console.log(
                "Attack finished. Attacker balance:",
                address(this).balance,
                " Contract balance",
                address(campaign).balance
            );
        }
    }

    function campaignId() external view returns (uint256) {
        return _campaignId;
    }

    receive() external payable {
        console.log("ENTERING RECEIVE");
        console.log("RECEIVE", msg.value);
        console.log(
            "Reentering withdraw. Attacker balance:",
            address(this).balance,
            " Contract balance",
            address(campaign).balance
        );
        if (address(campaign).balance >= msg.value) {
            campaign.withdraw(_campaignId, msg.value);
            console.log(
                "Reentered withdraw. Attacker balance:",
                address(this).balance,
                " Contract balance",
                address(campaign).balance
            );
        }
    }
}

contract ReentrancyTest is Test {
    Campaign public campaign;
    ReentrancyAttacker public attacker;
    address public funder;
    uint256 public campaignId;
    IDRX public mockIdrx;
    MockSwap public mockSwap;

    uint256 constant INITIAL_AMOUNT = 10 ether;
    uint256 constant CAMPAIGN_TARGET = 5 ether;
    uint256 constant DONATE_AMOUNT = 5 ether;
    uint256 constant WITHDRAW_AMOUNT = 1 ether;

    // 1 Base Native Token = 2684 IDRX (2 decimals)
    // For correct swap math in MockSwap, scaled by 100
    uint256 constant BASE_TO_IDRX = 26_840_000;

    function setUp() public {
        mockIdrx = new IDRX();
        mockSwap = new MockSwap();

        // Add IDRX to mockSwap with Base Native Token rate
        mockSwap.addToken(address(mockIdrx), BASE_TO_IDRX, mockIdrx.decimals());

        // Mint liquidity to mockSwap
        mockIdrx.mint(address(mockSwap), 1_000_000_000 * 10 ** mockIdrx.decimals());

        campaign = new Campaign(payable(address(mockSwap)), address(mockIdrx));
        funder = makeAddr("funder");
        vm.deal(funder, INITIAL_AMOUNT);
        attacker = new ReentrancyAttacker(address(campaign));
    }

    /**
     * @notice Test that IDRX (ERC20) withdrawals are inherently safe from reentrancy
     * @dev Since withdrawals are now in IDRX (ERC20), the receive() function is NOT called
     *      This makes reentrancy attacks impossible via the withdrawal mechanism
     *      The nonReentrant modifier provides additional protection
     */
    function testReentrancyIsPrevented() public {
        vm.startPrank(funder);
        console.log("CAMPAIGN ADDRESS", address(campaign));
        console.log("FUNDER BALANCE", address(funder).balance);

        // Attacker creates campaign and becomes owner
        campaignId = attacker.createMyCampaign("Attack", "Evil", CAMPAIGN_TARGET, address(mockIdrx));

        // Donate with Base Native Token (auto-swapped to IDRX)
        campaign.donate{value: DONATE_AMOUNT}(campaignId);

        // Calculate expected IDRX after swap
        uint256 expectedIDRX = (DONATE_AMOUNT * BASE_TO_IDRX) / 1e18;
        uint256 withdrawIDRX = expectedIDRX / 5; // Withdraw 1/5 of deposited IDRX

        console.log("CAMPAIGN IDRX BALANCE", mockIdrx.balanceOf(address(campaign)));
        console.log("WITHDRAW AMOUNT (IDRX)", withdrawIDRX);

        uint256 attackerBalanceBefore = mockIdrx.balanceOf(address(attacker));
        console.log("Attacker IDRX balance before:", attackerBalanceBefore);

        // The attack attempt - since IDRX is ERC20, receive() is NOT called
        // So the attacker's reentrancy attempt via receive() will never trigger
        // The withdrawal will succeed normally
        attacker.attack(withdrawIDRX);

        uint256 attackerBalanceAfter = mockIdrx.balanceOf(address(attacker));
        console.log("Attacker IDRX balance after:", attackerBalanceAfter);

        // Verify the attacker received IDRX but could not exploit reentrancy
        assertEq(attackerBalanceAfter, attackerBalanceBefore + withdrawIDRX, "Attacker should receive IDRX");

        // Verify campaign balance decreased correctly (no extra withdrawals from reentrancy)
        (,, uint256 remainingBalance,,,) = campaign.getCampaignInfo(campaignId);
        assertEq(
            remainingBalance, expectedIDRX - withdrawIDRX, "Campaign balance should decrease by exactly withdraw amount"
        );

        console.log("Reentrancy protection verified - ERC20 transfers don't trigger receive()");
        console.log("Campaign remaining balance:", remainingBalance);

        vm.stopPrank();
    }
}

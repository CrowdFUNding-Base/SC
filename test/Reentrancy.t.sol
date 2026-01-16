// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReentrancyAttacker {
    Campaign public campaign;
    address public _campaignAddr;
    bool public reentered;

    constructor(address _campaign) {
        campaign = Campaign(_campaign);
    }

    function createMyCampaign(string memory name, string memory creator, uint256 target) external returns (address) {
        console.log("Creating attacker's campaign... using contract", address(campaign));
        address addr = campaign.createCampaign(name, creator, target);
        console.log("Attacker's campaign created at:", addr);
        _campaignAddr = addr;
        return addr;
    }

    function attack(uint256 amount) external {
        // call withdraw from this contract (msg.sender inside Campaign will be this contract)
        console.log("Attacker contract attacking campaign at:", _campaignAddr);
        console.log("Starting attack. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
        campaign.withdraw(_campaignAddr, amount);
        console.log("Attack finished. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
    }

    function campaignAddr() external view returns (address) {
        return _campaignAddr;
    }


    receive() external payable {
        console.log("RECEIVE", msg.value);
        console.log("Reentering withdraw. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
        if(address(campaign).balance >= msg.value) {
            campaign.withdraw(_campaignAddr, msg.value);
        }
    }

    fallback() external payable {
        console.log("In fallback. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
    }
}

contract ReentrancyTest is Test {
    Campaign public campaign;
    ReentrancyAttacker public attacker;
    address public funder;
    IDRX public mockToken;

    uint256 constant INITIAL_AMOUNT = 10 ether;
    uint256 constant CAMPAIGN_TARGET = 2 ether;
    uint256 constant DONATE_AMOUNT = 3 ether;
    uint256 constant WITHDRAW_AMOUNT = 1 ether;

    function setUp() public {
        campaign = new Campaign();
        attacker = new ReentrancyAttacker(address(campaign));
        attacker.createMyCampaign("Attack", "Evil", CAMPAIGN_TARGET);
         (, , uint256 balance, , , address owner) = campaign.getCampaignInfo(attacker.campaignAddr());
        mockToken = new IDRX();
        funder = makeAddr("funder");
        mockToken.mint(funder, INITIAL_AMOUNT);
        vm.startPrank(funder);
        IERC20(mockToken).approve(address(campaign), INITIAL_AMOUNT);
        campaign.donate(attacker.campaignAddr(), INITIAL_AMOUNT, address(mockToken));
        vm.stopPrank();
    }

    function testReentrancyIsPrevented() public {
        hoax(funder);
        vm.expectRevert(
            abi.encodeWithSelector(
                Campaign.WithdrawalFailed.selector,
                address(attacker),
                "Attack",
                WITHDRAW_AMOUNT
            )
        );
        attacker.attack(WITHDRAW_AMOUNT);
    }
}

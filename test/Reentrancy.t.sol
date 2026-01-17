// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";
import {IDRX} from "../src/MockToken/MockIDRX.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReentrancyAttacker {
    Campaign public campaign;
    uint256 public _campaignId;
    bool public reentered;
    address public _tokenIn = address(0);

    constructor(address _campaign) {
        campaign = Campaign(_campaign);
    }

    function createMyCampaign(string memory name, string memory creator, uint256 target, address tokenIn) external returns (uint256) {
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
        if(_tokenIn != address(0)){
            console.log("Starting attack. Attacker balance:", IERC20(_tokenIn).balanceOf(address(this)), " Contract balance", IERC20(_tokenIn).balanceOf(address(campaign)));
            IERC20(_tokenIn).approve(address(campaign), amount);    
            campaign.withdraw(_campaignId, amount, _tokenIn);
            console.log("Attack finished. Attacker balance:", IERC20(_tokenIn).balanceOf(address(this)), " Contract balance", IERC20(_tokenIn).balanceOf(address(campaign)));
        }
        else{
            console.log("Starting attack. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
            campaign.withdraw(_campaignId, amount);
            console.log("Attack finished. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
        }
       
    }

    function campaignId() external view returns (uint256) {
        return _campaignId;
    }


    receive() external payable {
        console.log("ENTERING RECEIVE");
        console.log("RECEIVE", msg.value);
        console.log("Reentering withdraw. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
        if(address(campaign).balance >= msg.value) {
            campaign.withdraw(_campaignId, msg.value);
            console.log("Reentered withdraw. Attacker balance:", address(this).balance, " Contract balance", address(campaign).balance);
        }
    }
}

contract ReentrancyTest is Test {
    Campaign public campaign;
    ReentrancyAttacker public attacker;
    address public funder;
    uint256 public campaignId;
    IDRX public mockToken;

    uint256 constant INITIAL_AMOUNT = 10 ether;
    uint256 constant CAMPAIGN_TARGET = 5 ether;
    uint256 constant DONATE_AMOUNT = 5 ether;
    uint256 constant WITHDRAW_AMOUNT = 1 ether;

    function setUp() public {
        campaign = new Campaign();
        mockToken = new IDRX();
        funder = makeAddr("funder");
        vm.deal(funder, INITIAL_AMOUNT);
        attacker = new ReentrancyAttacker(address(campaign));
    }

    function testReentrancyIsPrevented() public {
        vm.startPrank(funder);
        console.log("CAMPAIGN ADDRESS", address(campaign));
        console.log("FUNDER BALANCE", address(funder).balance);
        campaignId = attacker.createMyCampaign("Attack", "Evil", CAMPAIGN_TARGET, address(0));
        campaign.donate{value: DONATE_AMOUNT}(campaignId, DONATE_AMOUNT);
        console.log("CAMPAIGN BALANCE", address(campaign).balance);
        vm.expectRevert(
            abi.encodeWithSelector(
                Campaign.WithdrawalFailed.selector,
                address(attacker),
                "Attack",
                WITHDRAW_AMOUNT
            )
        );
        attacker.attack(WITHDRAW_AMOUNT);
        vm.stopPrank();
    }
}

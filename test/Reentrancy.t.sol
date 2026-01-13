// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../src/Campaign.sol";

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

    function setUp() public {
        campaign = new Campaign();
        console.log("Campaign deployed at:", address(campaign));
        attacker = new ReentrancyAttacker(address(campaign));
        console.log("Attacker deployed at:", address(attacker));

        // Create a campaign owned by the attacker contract
        attacker.createMyCampaign("Attack", "Evil", 1 ether);
        console.log("Campaign to attack:", attacker.campaignAddr());
         (, , uint256 balance, , , address owner) = campaign.getCampaignInfo(attacker.campaignAddr());
        console.log("Attacker's campaign owner:", owner);

        // fund the attacker's campaign from another address
        funder = makeAddr("funder");
        vm.deal(funder, 10 ether);
        vm.startPrank(funder);
        campaign.donate{value: 10 ether}(attacker.campaignAddr(), 10 ether);
        console.log("Funder balance after donation:", funder.balance);
        console.log(address(campaign).balance, "campaign balance funded with 10 ether");
        vm.stopPrank();
    }

    function testReentrancyIsPrevented() public {
        // The inner reentrant call reverts (ReentrancyGuard), but because
        // the Campaign uses a low-level `call` to send funds, the outer
        // `withdraw` sees `success == false` and reverts with the
        // `WithdrawalFailed` custom error. Expect that error here.
        vm.expectRevert(
            abi.encodeWithSelector(
                Campaign.WithdrawalFailed.selector,
                address(attacker),
                "Attack",
                1 ether
            )
        );
        // Calling attack() will invoke withdraw() from the attacker contract,
        // which receives funds and then tries to reenter withdraw() in receive().
        attacker.attack(1 ether);
    }

 
}

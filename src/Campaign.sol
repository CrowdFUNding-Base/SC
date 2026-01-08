// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Campaign is ReentrancyGuard {
    struct CampaignStruct {
        string name;
        string creatorName;
        uint256 balance;
        uint256 targetAmount;
        uint256 creationTime;
        address owner;
    }
    mapping(address => CampaignStruct) private _campaigns;

    event CampaignCreated(address indexed campaignAddress, string name, string creatorName, address indexed owner, uint256 creationTime, uint256 targetAmount);
    event DonationReceived(address indexed campaignAddress, address indexed donor, uint256 amount);
    event FundWithdrawn(address indexed campaignAddress, string name, address indexed owner, string creatorName, uint256 amount);

    error CampaignAlreadyExists(string name);
    error CampaignNotFound(address campaignAddress);
    error AmountCannotBeLessOrEqualToZero(uint256 amount);
    error OnlyOwnerCanWithdraw(address caller);
    error InsufficientBalance(uint256 requested, uint256 available);
    error WithdrawalFailed(address to, string campaignName, uint256 amount);

    constructor() {}

    function createCampaign(string memory name, string memory creatorName, uint256 targetAmount) public returns (address) {
        // check if campaign with the same name already exists
        address campaignAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        if(bytes(_campaigns[campaignAddress].name).length != 0) {
            revert CampaignAlreadyExists(name);
        }

        _campaigns[campaignAddress] = CampaignStruct({
            name: name,
            creatorName: creatorName,   
            balance: 0,
            owner: msg.sender,
            creationTime: block.timestamp,
            targetAmount: targetAmount
        });
        emit CampaignCreated(campaignAddress, name, creatorName, msg.sender, block.timestamp, targetAmount);
        return campaignAddress;
    }

    function donate(address to, uint256 amount) public payable {
        if(amount <= 0) revert AmountCannotBeLessOrEqualToZero(amount);
        if(_campaigns[to].owner == address(0)) revert CampaignNotFound(to);
        
        _campaigns[to].balance += amount;
        emit DonationReceived(to, msg.sender, amount);
    }

    function withdraw(address campaignAddress, uint256 amount) public nonReentrant{
        CampaignStruct storage campaign = _campaigns[campaignAddress];
        if(campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if(amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        
        if(!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignAddress, campaign.name, msg.sender, campaign.creatorName, amount);
    }

    function getCampaignInfo(address campaignAddress) public view returns (string memory name, string memory creatorName, uint256 balance, uint256 targetAmount, uint256 creationTime, address owner) {
        CampaignStruct storage campaign = _campaigns[campaignAddress];
        if(campaign.owner == address(0)) revert CampaignNotFound(campaignAddress);
        return (campaign.name, campaign.creatorName, campaign.balance, campaign.targetAmount, campaign.creationTime, campaign.owner);
    }
}

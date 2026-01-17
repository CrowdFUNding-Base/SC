// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Campaign is ReentrancyGuard {
    struct CampaignStruct {
        string name;
        string creatorName;
        uint256 balance;
        uint256 targetAmount;
        uint256 creationTime;
        address owner;
    }
    mapping(uint256 => CampaignStruct) private _campaigns;
    uint256 private _currentTokenId = 0;

    event CampaignCreated(uint256 indexed campaignId, string name, string creatorName, address indexed owner, uint256 creationTime, uint256 targetAmount);
    event DonationReceived(uint256 indexed campaignId, address indexed donor, uint256 amount);
    event FundWithdrawn(uint256 indexed campaignId, string name, address indexed owner, string creatorName, uint256 amount);

    error CampaignAlreadyExists(string name);
    error CampaignNotFound(uint256 campaignId);
    error AmountMustBeGreaterThanZero(uint256 amount);
    error OnlyOwnerCanWithdraw(address caller);
    error InsufficientBalance(uint256 requested, uint256 available);
    error WithdrawalFailed(address to, string campaignName, uint256 amount);

    constructor() {}

    function createCampaign(string memory name, string memory creatorName, uint256 targetAmount) public returns (uint256) {
        // check if campaign with the same name already exists
        uint256 campaignId = _currentTokenId;
        _currentTokenId++;
        if(bytes(_campaigns[campaignId].name).length != 0) {
            revert CampaignAlreadyExists(name);
        }

        _campaigns[campaignId] = CampaignStruct({
            name: name,
            creatorName: creatorName,   
            balance: 0,
            owner: msg.sender,
            creationTime: block.timestamp,
            targetAmount: targetAmount
        });
        emit CampaignCreated(campaignId, name, creatorName, msg.sender, block.timestamp, targetAmount);
        return campaignId;
    }

    function donate(uint256 campaignId, uint256 amount) public payable {
        if(amount <= 0) revert AmountMustBeGreaterThanZero(amount);
        if(_campaigns[campaignId].owner == address(0)) revert CampaignNotFound(campaignId);
        _campaigns[campaignId].balance += amount;
        emit DonationReceived(campaignId, msg.sender, amount);
    }

    function donate(uint256 campaignId, uint256 amount, address tokenIn) public {
        if(amount <= 0) revert AmountMustBeGreaterThanZero(amount);
        if(_campaigns[campaignId].owner == address(0)) revert CampaignNotFound(campaignId);
        bool success = IERC20(tokenIn).transferFrom(msg.sender, address(this), amount);
        if(!success) revert WithdrawalFailed(msg.sender, _campaigns[campaignId].name, amount);
        else{
            _campaigns[campaignId].balance += amount;
            emit DonationReceived(campaignId, msg.sender, amount);
        }   
    }

    function withdraw(uint256 campaignId, uint256 amount) public nonReentrant{
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if(amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        if(!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignId, campaign.name, msg.sender, campaign.creatorName, amount);
    }

    function withdraw(uint256 campaignId, uint256 amount, address tokenIn) public nonReentrant{
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if(amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        bool success = IERC20(tokenIn).transfer(msg.sender, amount);
        if(!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignId, campaign.name, msg.sender, campaign.creatorName, amount);   
    }

    function getCampaignInfo(uint256 campaignId) public view returns (string memory name, string memory creatorName, uint256 balance, uint256 targetAmount, uint256 creationTime, address owner) {
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner == address(0)) revert CampaignNotFound(campaignId);
        return (campaign.name, campaign.creatorName, campaign.balance, campaign.targetAmount, campaign.creationTime, campaign.owner);
    }
}

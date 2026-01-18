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

    /// @notice Create a new campaign
    /// @param name The name of the campaign
    /// @param creatorName The name of the creator
    /// @param targetAmount The target amount of native currency to raise
    function createCampaign(string memory name, string memory creatorName, uint256 targetAmount) public returns (uint256) {
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

    /// @notice Donate to a campaign with native currency
    /// @param campaignId The ID of the campaign to donate to
    /// @param amount The amount of native currency to donate
    function donate(uint256 campaignId, uint256 amount) public payable {
        if(amount <= 0) revert AmountMustBeGreaterThanZero(amount);
        if(_campaigns[campaignId].owner == address(0)) revert CampaignNotFound(campaignId);
        _campaigns[campaignId].balance += amount;
        emit DonationReceived(campaignId, msg.sender, amount);
    }

    /// @notice Donate to a campaign with ERC20 token
    /// @param campaignId The ID of the campaign to donate to
    /// @param amount The amount of ERC20 token to donate
    /// @param tokenIn The address of the ERC20 token
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

    /// @notice Withdraw funds from a campaign
    /// @param campaignId The ID of the campaign to withdraw from
    /// @param amount The amount of native currency to withdraw 
    function withdraw(uint256 campaignId, uint256 amount) public nonReentrant{
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if(amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        if(!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignId, campaign.name, msg.sender, campaign.creatorName, amount);
    }

    /// @notice Withdraw ERC20 tokens from a campaign
    /// @param campaignId The ID of the campaign to withdraw from
    /// @param amount The amount of ERC20 token to withdraw
    /// @param tokenIn The address of the ERC20 token
    function withdraw(uint256 campaignId, uint256 amount, address tokenIn) public nonReentrant{
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if(amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        bool success = IERC20(tokenIn).transfer(msg.sender, amount);
        if(!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignId, campaign.name, msg.sender, campaign.creatorName, amount);   
    }

    /// @notice Get information about a campaign
    /// @param campaignId The ID of the campaign to get information about
    /// @return name The name of the campaign
    /// @return creatorName The name of the creator
    /// @return balance The balance of the campaign
    /// @return targetAmount The target amount of native currency to raise
    /// @return creationTime The creation time of the campaign
    /// @return owner The owner of the campaign
    function getCampaignInfo(uint256 campaignId) public view returns (string memory name, string memory creatorName, uint256 balance, uint256 targetAmount, uint256 creationTime, address owner) {
        CampaignStruct storage campaign = _campaigns[campaignId];
        if(campaign.owner == address(0)) revert CampaignNotFound(campaignId);
        return (campaign.name, campaign.creatorName, campaign.balance, campaign.targetAmount, campaign.creationTime, campaign.owner);
    }
}

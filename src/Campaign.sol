// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MockSwap} from "./MockSwap.sol";

contract Campaign is ReentrancyGuard {
    using SafeERC20 for IERC20;

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

    // MockSwap contract for token swaps
    MockSwap public mockSwap;
    // Storage token - all donations are converted to this token
    address public storageToken;

    event CampaignCreated(
        uint256 indexed campaignId,
        string name,
        string creatorName,
        address indexed owner,
        uint256 creationTime,
        uint256 targetAmount
    );
    event DonationReceived(uint256 indexed campaignId, address indexed donor, uint256 amount);
    event FundWithdrawn(
        uint256 indexed campaignId, string name, address indexed owner, string creatorName, uint256 amount
    );

    error CampaignAlreadyExists(string name);
    error CampaignNotFound(uint256 campaignId);
    error AmountMustBeGreaterThanZero(uint256 amount);
    error OnlyOwnerCanWithdraw(address caller);
    error InsufficientBalance(uint256 requested, uint256 available);
    error WithdrawalFailed(address to, string campaignName, uint256 amount);
    error SwapFailed();

    /// @param _mockSwap Address of the MockSwap contract
    /// @param _storageToken Address of the token to store donations in (e.g., IDRX)
    constructor(address payable _mockSwap, address _storageToken) {
        mockSwap = MockSwap(_mockSwap);
        storageToken = _storageToken;
    }

    /// @notice Create a new campaign
    /// @param name The name of the campaign
    /// @param creatorName The name of the creator
    /// @param targetAmount The target amount of native currency to raise
    function createCampaign(string memory name, string memory creatorName, uint256 targetAmount)
        public
        returns (uint256)
    {
        uint256 campaignId = _currentTokenId;
        _currentTokenId++;
        if (bytes(_campaigns[campaignId].name).length != 0) {
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

    /// @notice Donate to a campaign with native currency (ETH)
    /// @dev The ETH is automatically swapped to storageToken (IDRX) before storing
    /// @param campaignId The ID of the campaign to donate to
    function donate(uint256 campaignId) public payable nonReentrant {
        if (msg.value <= 0) revert AmountMustBeGreaterThanZero(msg.value);
        if (_campaigns[campaignId].owner == address(0)) revert CampaignNotFound(campaignId);

        // Get balance before swap
        uint256 balanceBefore = IERC20(storageToken).balanceOf(address(this));

        // Swap ETH to storageToken (IDRX)
        mockSwap.swapETHForToken{value: msg.value}(storageToken);

        // Calculate how much storageToken we received
        uint256 balanceAfter = IERC20(storageToken).balanceOf(address(this));
        uint256 amountToStore = balanceAfter - balanceBefore;

        if (amountToStore == 0) revert SwapFailed();

        _campaigns[campaignId].balance += amountToStore;
        emit DonationReceived(campaignId, msg.sender, amountToStore);
    }

    /// @notice Donate to a campaign with ERC20 token (auto-swaps to storageToken)
    /// @param campaignId The ID of the campaign to donate to
    /// @param amount The amount of ERC20 token to donate
    /// @param tokenIn The address of the ERC20 token being donated
    function donate(uint256 campaignId, uint256 amount, address tokenIn) public nonReentrant {
        if (amount <= 0) revert AmountMustBeGreaterThanZero(amount);
        if (_campaigns[campaignId].owner == address(0)) revert CampaignNotFound(campaignId);

        uint256 amountToStore;

        if (tokenIn == storageToken) {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amount);
            amountToStore = amount;
        } else {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amount);
            IERC20(tokenIn).approve(address(mockSwap), amount);
            uint256 balanceBefore = IERC20(storageToken).balanceOf(address(this));
            mockSwap.swap(tokenIn, storageToken, amount);
            uint256 balanceAfter = IERC20(storageToken).balanceOf(address(this));
            amountToStore = balanceAfter - balanceBefore;
            if (amountToStore == 0) revert SwapFailed();
        }

        _campaigns[campaignId].balance += amountToStore;
        emit DonationReceived(campaignId, msg.sender, amountToStore);
    }

    /// @notice Withdraw funds from a campaign in storageToken (IDRX)
    /// @dev All balances are stored in IDRX, so withdrawal is always in IDRX
    /// @param campaignId The ID of the campaign to withdraw from
    /// @param amount The amount of storageToken (IDRX) to withdraw
    function withdraw(uint256 campaignId, uint256 amount) public nonReentrant {
        CampaignStruct storage campaign = _campaigns[campaignId];
        if (campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if (amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        // Transfer storageToken (IDRX) instead of native ETH
        bool success = IERC20(storageToken).transfer(msg.sender, amount);
        if (!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
        else emit FundWithdrawn(campaignId, campaign.name, msg.sender, campaign.creatorName, amount);
    }

    /// @notice Withdraw ERC20 tokens from a campaign
    /// @param campaignId The ID of the campaign to withdraw from
    /// @param amount The amount of ERC20 token to withdraw
    /// @param tokenIn The address of the ERC20 token
    function withdraw(uint256 campaignId, uint256 amount, address tokenIn) public nonReentrant {
        CampaignStruct storage campaign = _campaigns[campaignId];
        if (campaign.owner != msg.sender) revert OnlyOwnerCanWithdraw(msg.sender);
        if (amount > campaign.balance) revert InsufficientBalance(amount, campaign.balance);

        campaign.balance -= amount;
        bool success = IERC20(tokenIn).transfer(msg.sender, amount);
        if (!success) revert WithdrawalFailed(msg.sender, campaign.name, amount);
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
    function getCampaignInfo(uint256 campaignId)
        public
        view
        returns (
            string memory name,
            string memory creatorName,
            uint256 balance,
            uint256 targetAmount,
            uint256 creationTime,
            address owner
        )
    {
        CampaignStruct storage campaign = _campaigns[campaignId];
        if (campaign.owner == address(0)) revert CampaignNotFound(campaignId);
        return (
            campaign.name,
            campaign.creatorName,
            campaign.balance,
            campaign.targetAmount,
            campaign.creationTime,
            campaign.owner
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MockSwap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct TokenInfo {
        address token;
        uint256 decimals;
        uint256 ethToToken; // 1 ETH = X tokens (in token's smallest unit)
    }

    mapping(address => TokenInfo) public tokenInfos;

    event TokenAdded(address indexed token, uint256 decimals, uint256 ethToToken);
    event SwapToken(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    error TokenAlreadyAdded(address token);
    error InvalidToken(address token);

    constructor() Ownable(msg.sender) {}

    /// @notice Add a new token to the swap contract
    /// @param token The address of the token to add
    /// @param ethToToken How many tokens equal 1 ETH (in token's smallest unit)
    ///        Example: 1 ETH = 3000 USDC → ethToToken = 3000 * 10^6 = 3_000_000_000
    ///        Example: 1 ETH = 48M IDRX → ethToToken = 48_000_000 * 10^2 (if 2 decimals)
    /// @param decimals The token's decimals
    function addToken(address token, uint256 ethToToken, uint256 decimals) external onlyOwner {
        if (tokenInfos[token].token != address(0)) revert TokenAlreadyAdded(token);
        if (decimals == 0) revert InvalidToken(token);
        tokenInfos[token] = TokenInfo({token: token, decimals: decimals, ethToToken: ethToToken});
        emit TokenAdded(token, decimals, ethToToken);
    }

    /// @notice Swap tokens
    /// @param tokenIn The address of the token to swap
    /// @param tokenOut The address of the token to receive
    /// @param amountIn The amount of tokens to swap
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external nonReentrant {
        if (tokenInfos[tokenIn].token == address(0)) revert InvalidToken(tokenIn);
        if (tokenInfos[tokenOut].token == address(0)) revert InvalidToken(tokenOut);
        if (tokenIn == tokenOut) return;

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        TokenInfo memory inInfo = tokenInfos[tokenIn];
        TokenInfo memory outInfo = tokenInfos[tokenOut];

        uint256 normalizedIn = amountIn * (10 ** (18 - inInfo.decimals));
        uint256 ethEquivalent = (normalizedIn * 1e18) / inInfo.ethToToken;
        uint256 normalizedOut = (ethEquivalent * outInfo.ethToToken) / 1e18;
        uint256 amountOut = normalizedOut / (10 ** (18 - outInfo.decimals));

        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
        emit SwapToken(tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Get quote for a swap (view only)
    /// @param tokenIn The address of the token to swap
    /// @param tokenOut The address of the token to receive
    /// @param amountIn The amount of tokens to swap
    /// @return amountOut The expected output amount
    function getQuote(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut) {
        TokenInfo memory inInfo = tokenInfos[tokenIn];
        TokenInfo memory outInfo = tokenInfos[tokenOut];

        uint256 normalizedIn = amountIn * (10 ** (18 - inInfo.decimals));
        uint256 ethEquivalent = (normalizedIn * 1e18) / inInfo.ethToToken;
        uint256 normalizedOut = (ethEquivalent * outInfo.ethToToken) / 1e18;
        amountOut = normalizedOut / (10 ** (18 - outInfo.decimals));
    }

    /// @notice Get token info
    function getTokenInfo(address token) external view returns (address, uint256, uint256) {
        TokenInfo memory info = tokenInfos[token];
        return (info.token, info.decimals, info.ethToToken);
    }

    /// @notice Swap native ETH for tokens
    /// @param tokenOut The address of the token to receive
    /// @return amountOut The amount of tokens received
    function swapETHForToken(address tokenOut) external payable nonReentrant returns (uint256 amountOut) {
        if (tokenInfos[tokenOut].token == address(0)) revert InvalidToken(tokenOut);
        if (msg.value == 0) revert InvalidToken(address(0));

        TokenInfo memory outInfo = tokenInfos[tokenOut];

        // ETH has 18 decimals, calculate output based on ethToToken rate
        // msg.value is in wei (10^18 = 1 ETH)
        // ethToToken is how many tokens per 1 ETH (in token's smallest unit)
        // amountOut = (msg.value * ethToToken) / 10^18
        amountOut = (msg.value * outInfo.ethToToken) / 1e18;

        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
        emit SwapToken(address(0), tokenOut, msg.value, amountOut);
    }

    /// @notice Get quote for ETH to token swap (view only)
    /// @param tokenOut The address of the token to receive
    /// @param ethAmount The amount of ETH to swap (in wei)
    /// @return amountOut The expected output amount
    function getQuoteETH(address tokenOut, uint256 ethAmount) external view returns (uint256 amountOut) {
        TokenInfo memory outInfo = tokenInfos[tokenOut];
        // Same calculation as swapETHForToken
        amountOut = (ethAmount * outInfo.ethToToken) / 1e18;
    }

    /// @notice Allow contract to receive ETH
    receive() external payable {}
}

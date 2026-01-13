// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MockToken} from "./MockToken.sol";

contract FactoryToken{
    function createToken(string memory name, string memory symbol, uint256 initialSupply) public returns (address) {
        address token = address(new MockToken(name, symbol, initialSupply));
        return token;
    }

    function mintToken(address tokenAddress, uint256 amount) public {
        MockToken(tokenAddress).mint(amount);
    }
}
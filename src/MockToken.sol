// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC20} from "openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

contract MockToken is ERC20, Ownable{
    string private _name;
    string private _symbol;

    error TransferFailed(string reason);

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) Ownable(msg.sender) {
        _name = name;
        _symbol = symbol;
        _mint(msg.sender, initialSupply);
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function getName() public view returns (string memory) {
        return _name;
    }

    function getSymbol() public view returns (string memory) {
        return _symbol;
    }

    function transferTokens(address to, uint256 amount) public {
        (bool success, ) = to.call{value: amount}("");
        if(!success) revert TransferFailed("Transfer failed.");
     }
}
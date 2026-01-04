// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Vault {
    mapping(address => uint256) private _balances;

    function createVault(string memory name) public returns (address) {
        address to = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        _balances[to] = 0;
        return to;
    }

    function donate(address to, uint256 amount) public payable {
        _balances[to] += amount;
    }
}

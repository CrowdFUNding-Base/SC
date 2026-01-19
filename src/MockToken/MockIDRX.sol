// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
 * @title IDRX
 * @author CrowdFUNding
 * @notice This contract is a mock token for testing purposes
 */
contract IDRX is ERC20{ 
    /*
    * @dev constructor
    * @param name name of the token
    * @param symbol symbol of the token
    */
    constructor() ERC20("IDRX", "IDRX") {}
    /*
    * @dev decimals
    * @return uint8
    */
    function decimals() public pure override returns (uint8) {
        return 2;
    }
    /*
    * @dev mint
    * @param _to address
    * @param _amount uint256
    */
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
    /*
    * @dev burn
    * @param _to address
    * @param _amount uint256
    */
    function burn(address _to, uint256 _amount) public {
        _burn(_to, _amount);
    }
}
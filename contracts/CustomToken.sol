// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomToken is ERC20 {
    /**
      * @notice CustomToken is simple contract to show examples how to use hardhat: tests, deploys, tasks etc.
      * @dev CustomToken is ERC20 which mint tokens when you deploy this contract
      * @param _name is name of the ERC20 token
      * @param _symbol is symbol of the ERC20 token
      * @param _amount is amount of the ERC20 token
      */
    constructor(string memory _name, string memory _symbol, uint256 _amount) ERC20(_name, _symbol) {
        _mint(msg.sender, _amount);
    }
}

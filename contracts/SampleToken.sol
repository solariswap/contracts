// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SampleToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _liquidity) ERC20(_name, _symbol) {
        _mint(msg.sender, _liquidity);
    }
}

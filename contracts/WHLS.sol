// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Script.sol";

contract WHLS is ERC20 {
    address public immutable nativeToken;

    constructor() ERC20("Wrapped HLS", "WHLS") {
        nativeToken = address(0);
    }

    // Fallback function to accept HLS (if it's native to your chain)
    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient WHLS");
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}

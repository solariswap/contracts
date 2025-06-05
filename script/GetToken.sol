// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract GetToken is Script {
    function run() external {
        IERC20 token = IERC20(0x6e4dab0F87420B9D57544E6A842dAd96F26C0070);

        console.log("Name", token.name());
    }
}

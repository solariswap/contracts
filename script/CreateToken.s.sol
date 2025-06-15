// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "../contracts/SampleToken.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract CreateTokenScript is Script {
    function run() external {
        vm.startBroadcast();

        SampleToken token = new SampleToken("KRK", "KRK Token", 1e6 ether);

        console.log(address(token));

        vm.stopBroadcast();
    }
}

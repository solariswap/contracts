// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "../src/SolariSwap.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {INonfungiblePositionManager} from "v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

contract CollectFeesScript is Script {
    SolariSwap public immutable solariSwap;

    constructor() {
        solariSwap = SolariSwap(0x78EF05c52657130987b6260E87f53899144B1Aab);
    }

    function run() external {
        vm.startBroadcast();
        uint256 tokenId = solariSwap.posm().tokenOfOwnerByIndex(msg.sender, 0);
        console.log("tokenId", tokenId);

        (, uint128 liquidity, ,) = solariSwap.deposits(tokenId);

        console.log("Liquidity Deposited:", uint256(liquidity));

        solariSwap.posm().collect(INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: msg.sender,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        }));

        vm.stopBroadcast();
    }
}

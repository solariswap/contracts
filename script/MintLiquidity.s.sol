// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SolariSwap} from "../src/SolariSwap.sol";
import {TickMath} from "v3-core/contracts/libraries/TickMath.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract MintLiquidityScript is Script {
    SolariSwap public immutable solariSwap;

    constructor() {
        solariSwap = SolariSwap(0x3CCd65D81d84eF4CB3175710b4c6D70ca5068E77);
    }

    function run() external {
        address TEST = 0x7419C891CCC5a19ab4c6A836E2b1536e25DFbb27;
        address WHLS = 0xD4949664cD82660AaE99bEdc034a0deA8A0bd517;
        uint24 plFee = 3000;

        uint256 amount0 = 10e18;
        uint256 amount1 = 2e18;
        uint256 amount0Min = 0;
        uint256 amount1Min = 0;
        int24 tickLower = -887220;
        int24 tickUpper = 887220;
//        int24 tickLower = -120;
//        int24 tickUpper = 120;

        vm.startBroadcast();

        IERC20(TEST).approve(address(solariSwap), amount0);
        IERC20(WHLS).approve(address(solariSwap), amount1);



        uint256 balance = IERC20(WHLS).balanceOf(0x0Bee445Fb0E187a4cf9D7155314883eef83D64B8);
        console.log("balance", balance);
//        uint256 tokenId = solariSwap.mintLiquidity(TEST, WHLS, plFee, amount0, amount1, amount0Min, amount1Min, tickLower, tickUpper);
//        console.log("Token Id", tokenId);
        vm.broadcast();
    }
}

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
        solariSwap = SolariSwap(0x78EF05c52657130987b6260E87f53899144B1Aab);
    }

    function run() external {
        address TEST = 0x3CCd65D81d84eF4CB3175710b4c6D70ca5068E77;
        address WHLS = vm.envAddress("WETH9_ADDRESS");
        uint24 plFee = 3000;

        uint256 amount0 = 50e18;
        uint256 amount1 = 100e18;
        uint256 amount0Min = 0;
        uint256 amount1Min = 0;
        int24 tickLower = -887220;
        int24 tickUpper = 887220;
//        int24 tickLower = -120;
//        int24 tickUpper = 120;

        vm.startBroadcast();

        IERC20(TEST).approve(address(solariSwap), amount0);
        IERC20(WHLS).approve(address(solariSwap), amount1);

        vm.stopBroadcast();

        vm.broadcast();

        uint256 tokenId = solariSwap.mintLiquidity(TEST, WHLS, plFee, amount0, amount0Min, amount1Min,  amount1, tickLower, tickUpper);
        console.log("Token Id", tokenId);
    }
}

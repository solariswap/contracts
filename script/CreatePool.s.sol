// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SolariSwap} from "../src/SolariSwap.sol";
import {TickMath} from "v3-core/contracts/libraries/TickMath.sol";

contract CreatePoolScript is Script {
    SolariSwap public immutable solariSwap;

    constructor() {
        solariSwap = SolariSwap(0x78EF05c52657130987b6260E87f53899144B1Aab);
    }

    function run() external {
        address WHLS = vm.envAddress("WETH9_ADDRESS");
        address TEST = 0x3CCd65D81d84eF4CB3175710b4c6D70ca5068E77;
        uint24 plFee = 500;
        int24 initialTick = getInitialTick(1, 2);

        vm.startBroadcast();

        address poolAddress = solariSwap.createPool(WHLS, TEST, plFee, initialTick);
        console.log("Pool Address:", poolAddress);

        vm.stopBroadcast();
    }

    function getInitialTick(uint256 amount0, uint256 amount1) public pure returns (int24 tick) {
        require(amount0 > 0 && amount1 > 0, "Amounts must be > 0");

        uint256 priceX96 = (amount1 << 96) / amount0; // Q64.96 format
        uint160 sqrtPriceX96 = uint160(sqrt(priceX96 << 96)); // sqrt in Q64.96

        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

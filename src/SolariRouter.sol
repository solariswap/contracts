// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "v3-periphery/contracts/libraries/TransferHelper.sol";
import {SwapRouter} from "v3-periphery/contracts/SwapRouter.sol";
import 'v3-periphery/contracts/libraries/PoolAddress.sol';


contract SolariRouter is SwapRouter {
    constructor() SwapRouter(0xbaf4191798ebFc5AF135585cD7DEAE687612c510, 0x6e4dab0F87420B9D57544E6A842dAd96F26C0070) {}
}

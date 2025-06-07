// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "v3-periphery/contracts/libraries/TransferHelper.sol";
import {SwapRouter} from "v3-periphery/contracts/SwapRouter.sol";
import 'v3-periphery/contracts/libraries/PoolAddress.sol';

contract SolariRouter is SwapRouter {
    constructor() SwapRouter(0xd60f84942Bf4380673ae9642a489955ee4aeCe38, 0xD4949664cD82660AaE99bEdc034a0deA8A0bd517) {}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TransferHelper} from "v3-periphery/contracts/libraries/TransferHelper.sol";
import {ISwapRouter} from "v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "v3-periphery/contracts/interfaces/IQuoterV2.sol";

contract SwapScript is Script {
    ISwapRouter public immutable router;
    IQuoterV2 public immutable quoter;

    constructor(){
        router = ISwapRouter(0x4947CDB6d311F631242d051327190500Ee46f7C9);
        quoter = IQuoterV2(0xE885c930B813C833c98E4f0987c8fcF2B845612B);
    }

    function run() external {
        address WHLS = vm.envAddress("WETH9_ADDRESS");
        address KRK = 0x7419C891CCC5a19ab4c6A836E2b1536e25DFbb27;

        uint24 plFee = 3000;

        uint256 amountIn = 10e18;

        vm.startBroadcast();
        (uint256 amountOut, , ,) = quoter.quoteExactInputSingle(IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: WHLS,
            tokenOut: KRK,
            fee: plFee,
            amountIn: amountIn,
            sqrtPriceLimitX96: 0
        }));

        console.log("Amount Out", amountOut);

//        TransferHelper.safeApprove(TEST, address(router), amountIn);

//        ISwapRouter.ExactInputSingleParams memory params =
//            ISwapRouter.ExactInputSingleParams({
//                tokenIn: TEST,
//                tokenOut: WHLS,
//                fee: plFee,
//                recipient: msg.sender,
//                deadline: block.timestamp + 60,
//                amountIn: amountIn,
//                amountOutMinimum: 0,
//                sqrtPriceLimitX96: 0
//            });

//        uint256 amountOut = router.exactInputSingle(params);
//        console.log("amountIn", amountIn);
//        console.log("AmountOut", amountOut);
        vm.stopBroadcast();
    }
}

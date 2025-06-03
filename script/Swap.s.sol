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
        quoter = IQuoterV2(0x38DfC353aDAFC24B68f13d2f5Bf9FDF6B0B82484);
    }

    function run() external {
        address WHLS = vm.envAddress("WETH9_ADDRESS");
        address TEST = 0x3CCd65D81d84eF4CB3175710b4c6D70ca5068E77;

        uint24 plFee = 3000;

        uint256 amountIn = 10e18;

        vm.startBroadcast();
//        (uint256 amountOut, , ,) = quoter.quoteExactInputSingle(IQuoterV2.QuoteExactInputSingleParams({
//            tokenIn: TEST,
//            tokenOut: WHLS,
//            fee: plFee,
//            amountIn: amountIn,
//            sqrtPriceLimitX96: 0
//        }));

//        console.log("Amount Out", amountOut);

        TransferHelper.safeApprove(TEST, address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: TEST,
                tokenOut: WHLS,
                fee: plFee,
                recipient: msg.sender,
                deadline: block.timestamp + 60,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = router.exactInputSingle(params);
        console.log("amountIn", amountIn);
        console.log("AmountOut", amountOut);
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IUniswapV3Factory} from "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {TransferHelper} from "v3-periphery/contracts/libraries/TransferHelper.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {TickMath} from "v3-core/contracts/libraries/TickMath.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

contract CreatePoolAndAddLiquidityScript is IERC721Receiver, Script   {
    INonfungiblePositionManager public immutable posm;
    uint24 public plFee = 10000;

    constructor() {
        posm = INonfungiblePositionManager(vm.envAddress("NF_POSITION_MANAGER_ADDRESS"));
    }

    /// @notice Represents the deposit of an NFT
    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    mapping(uint256 => Deposit) public deposits;

    function run() external {
        IUniswapV3Factory factory = IUniswapV3Factory(vm.envAddress("UNISWAP_V3_FACTORY_ADDRESS"));

        (address tokenA, address tokenB) = _sortTokens(vm.envAddress("WETH9_ADDRESS"), 0xb686E202aFA45350aF6b74B5f92D4519B86b2747);

        address poolAddr = factory.getPool(tokenA, tokenB, plFee);
        uint256 amountA = 100e18;
        uint256 amountB = 500e18;
        uint160 sqrtPrice = _encodeSqrtRatioX96(amountA, amountB);

        console.log("Token A:", tokenA);
        console.log("Token B:", tokenB);

        vm.startBroadcast();

        // Create the pool if not existing
        if (poolAddr == address(0)) {
            poolAddr = _createPool(factory, tokenA, tokenB, plFee);
        }


        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        (uint160 sqrtPriceX96, , , , , ,) = pool.slot0();

        if (sqrtPriceX96 == 0) {
            pool.initialize(sqrtPrice);

        }

        _approveToken(posm, IERC20(tokenA), amountA);
        _approveToken(posm, IERC20(tokenB), amountB);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: tokenA,
            token1: tokenB,
            fee: plFee,
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amountA,
            amount1Desired: amountB,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 60
        });
        (uint256 tokenId, , uint256 amount0, uint256 amount1) = _mintLiquidity(posm, params);

        _createDeposit(msg.sender, tokenId);

        // Remove allowance and refund in both assets.
        _handleRefund(tokenA, amountA, amount0, posm);
        _handleRefund(tokenB, amountB, amount1, posm);

        vm.stopBroadcast();
    }

    function _handleRefund(address token, uint256 desired, uint256 used, INonfungiblePositionManager posm) internal {
        if (used < desired) {
            TransferHelper.safeApprove(token, address(posm), 0);
            uint256 refund = desired - used;
            TransferHelper.safeTransfer(token, msg.sender, refund);
        }
    }

    function _createPool(IUniswapV3Factory factory, address tokenA, address tokenB, uint24 plFee) internal returns (address) {
        address pool = factory.createPool(tokenA, tokenB, plFee);

        return pool;
    }

    function _mintLiquidity(INonfungiblePositionManager posm, INonfungiblePositionManager.MintParams memory params)
        internal
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        return posm.mint(params);
    }

    function _approveToken(INonfungiblePositionManager posm, IERC20 token, uint256 amount) internal {
        uint256 allowance = token.allowance(msg.sender, address(posm));
        if (allowance >= amount) return;

        console.log("Approved Token, Amount:", amount);

        TransferHelper.safeApprove(address(token), address(posm), amount);
    }

    function _sortTokens(address tokenA, address tokenB) internal pure returns (address, address) {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    /**
 * @notice Encode a price between token0 and token1 as a sqrt ratio x96
     * @notice In case when decimals are the same
     * do not use price including decimals
     * In case when decimals are not the same
     * use price including decimals
     * Example:
     * 1 ETH = 1000 USDC (USDC = 6 decimals)
     * 1 ETH = 1000e6 USDC
     * amount0 = 1 ether; // 1+18 decimals
     * amount1 = 1000e6; // 1000+6 decimals
     * @param amount1 The amount of token1 as a price
     * @param amount0 The amount of token0 as a price
     * @return sqrtPriceX96 The encoded price
     */
    function _encodeSqrtRatioX96(uint256 amount1, uint256 amount0) internal pure returns (uint160 sqrtPriceX96) {
        require(amount0 > 0 && amount1 > 0, "Amounts must be non-zero");

        // Fixed point Q96 calculation:
        // (sqrt(amount1 / amount0) * 2^96) == sqrt((amount1 << 192) / amount0)
        uint256 ratioX192 = (amount1 << 192) / amount0;
        return uint160(_sqrt(ratioX192));
    }

    function _sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) return 0;
        // Initial guess: the largest power of 2 smaller than or equal to the square root of x
        uint256 z = (x + 1) / 2;
        result = x;

        // Babylonian method: iteratively improve guess
        while (z < result) {
            result = z;
            z = (x / z + z) / 2;
        }
    }

    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information

        _createDeposit(operator, tokenId);

        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
//        (, , address token0, address token1, , , , uint128 liquidity, , , , ) =
//                            posm.positions(tokenId);

        // set the owner and data for position
        // operator is msg.sender
//        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }
}

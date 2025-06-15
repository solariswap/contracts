// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "v3-periphery/contracts/libraries/TransferHelper.sol";
import {INonfungiblePositionManager} from "v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IUniswapV3Factory} from "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {TickMath} from "v3-core/contracts/libraries/TickMath.sol";

contract SolariSwap {
    INonfungiblePositionManager public immutable posm;
    IUniswapV3Factory public immutable factory;

    event PoolCreated(address indexed token0, address indexed token1, uint24 fee, address pool, uint160 initialPrice);
    event LiquidityMinted(address indexed provider, uint256 indexed tokenId, uint128 liquidity);
    event PositionWithdrawn(uint256 indexed tokenId, address indexed owner);

    constructor(address _posm, address _factory) {
        posm = INonfungiblePositionManager(_posm);
        factory = IUniswapV3Factory(_factory);
    }

    /// @notice Creates and initializes a Uniswap V3 pool between two tokens with a specific fee tier.
    /// @param token0 One of the tokens in the pair
    /// @param token1 The other token in the pair
    /// @param plFee The pool fee tier (e.g., 3000 for 0.3%)
    /// @param initialTick Initial tick (price) to initialize the pool at
    /// @return poolAddress The address of the newly created pool
    function createPool(address token0, address token1, uint24 plFee, int24 initialTick) external returns (address poolAddress) {
        require(token0 != token1, "Identical tokens");
        require(token0 != address(0) && token1 != address(0), "Zero address token");

        // Ensure token ordering matches Uniswap's requirement (token0 < token1)
        (address sToken0, address sToken1) = _sortTokens(token0, token1);

        address pool = factory.getPool(sToken0, sToken1, plFee);
        require(pool == address(0), "Pool already created");

        poolAddress = factory.createPool(sToken0, sToken1, plFee);
        require(poolAddress != address(0), "Pool creation failed");

        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(initialTick);
        IUniswapV3Pool(poolAddress).initialize(sqrtPriceX96);
        emit PoolCreated(sToken0, sToken1, plFee, poolAddress, sqrtPriceX96);
    }

    /// @notice Adds liquidity to a Uniswap V3 position and mints an NFT representing the position
    /// @dev Tokens must be provided in sorted order (tokenA < tokenB)
    /// @dev Caller must approve this contract to spend their tokens
    /// @param token0 The first token of the pair (must be lower address than tokenB)
    /// @param token1 The second token of the pair (must be higher address than tokenA)
    /// @param plFee The fee tier of the pool
    /// @param amount0 The desired amount of tokenA to add as liquidity
    /// @param amount1 The desired amount of tokenB to add as liquidity
    /// @param amount0Min The minimum amount of tokenA to add as liquidity
    /// @param amount1Min The minimum amount of tokenB to add as liquidity
    /// @param tickLower The lower tick of the position's price range
    /// @param tickUpper The upper tick of the position's price range
    /// @return tokenId The ID of the NFT representing the minted position
    function mintLiquidity(address token0, address token1, uint24 plFee, uint256 amount0, uint256 amount1, uint256 amount0Min, uint256 amount1Min, int24 tickLower, int24 tickUpper) external returns (uint256) {
        require(tickLower < tickUpper, "Invalid ticks");

        (address sToken0, address sToken1) = _sortTokens(token0, token1);

        require(IERC20(sToken0).transferFrom(msg.sender, address(this), amount0), "Transfer token0 failed");
        require(IERC20(sToken1).transferFrom(msg.sender, address(this), amount1), "Transfer token1 failed");

        IERC20(sToken0).approve(address(posm), amount0);
        IERC20(sToken1).approve(address(posm), amount1);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: sToken0,
            token1: sToken1,
            fee: plFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: msg.sender,
            deadline: block.timestamp
        });

        (uint256 tokenId, uint128 liquidity, uint256 amount0Used, uint256 amount1Used) = posm.mint(params);

        // Remove allowance and refund in both assets.
        if (amount0Used < amount0) {
            TransferHelper.safeApprove(sToken0, address(posm), 0);
            uint256 refund0 = amount0 - amount0Used;
            TransferHelper.safeTransfer(sToken0, msg.sender, refund0);
        }

        if (amount1Used < amount1) {
            TransferHelper.safeApprove(sToken1, address(posm), 0);
            uint256 refund1 = amount1 - amount1Used;
            TransferHelper.safeTransfer(sToken1, msg.sender, refund1);
        }

        emit LiquidityMinted(msg.sender, tokenId, liquidity);

        return tokenId;
    }

    function _sortTokens(address token0, address token1) internal pure returns (address, address) {
        return token0 < token1 ? (token0, token1) : (token1, token0);
    }
}

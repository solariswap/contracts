set dotenv-load := true

default:
    @just --choose

setup:
    forge install

deploy-wrapped-hls:
    forge create --broadcast contracts/WHLS.sol:WHLS --private-key $PRIVATE_KEY --rpc-url $RPC_URL

deploy-solari-swap:
    forge create src/SolariSwap.sol:SolariSwap --broadcast --rpc-url $RPC_URL --private-key $PRIVATE_KEY --constructor-args $NF_POSITION_MANAGER_ADDRESS $UNISWAP_V3_FACTORY_ADDRESS

deploy-router:
    forge create src/SolariRouter.sol:SolariRouter --broadcast --rpc-url $RPC_URL --private-key $PRIVATE_KEY

create-pool-and-add-liquidity:
    forge script --broadcast script/CreatePoolAndAddLiquidity.s.sol:CreatePoolAndAddLiquidityScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL

create-pool:
    forge script --broadcast script/CreatePool.s.sol:CreatePoolScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL

mint-liquidity:
    forge script --broadcast script/MintLiquidity.s.sol:MintLiquidityScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL

collect-fees:
    forge script --broadcast script/CollectFees.s.sol:CollectFeesScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL

swap:
    forge script --broadcast script/Swap.s.sol:SwapScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL

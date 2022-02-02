// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;

/*
 *        _   _   _  _     ___   __   __   ___     ___     ___     ___
 *       | | | | | \| |   |_ _|  \ \ / /  | __|   | _ \   / __|   | __|
 *       | |_| | | .` |    | |    \ V /   | _|    |   /   \__ \   | _|
 *        \___/  |_|\_|   |___|   _\_/_   |___|   |_|_\   |___/   |___|
 *      _|"""""|_|"""""|_|"""""|_| """"|_|"""""|_|"""""|_|"""""|_|"""""|
 *      "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'
 *
 */

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "../interfaces/UNTERC20.sol";
import "../interfaces/IERC20Detail.sol";
import "../interfaces/PositionHelper.sol";
import "../interfaces/IUniversePairVault.sol";

contract UniversePairVault is IUniversePairVault, Ownable, UNTERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using PositionHelper for PositionHelper.Position;

    // Uni POOL
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    // Important Addresses
    address immutable uniFactory;
    address operator;
    /// @inheritdoc IUniversePairVault
    IERC20 public immutable override token0;
    /// @inheritdoc IUniversePairVault
    IERC20 public immutable override token1;
    mapping(address => bool) poolMap;

    // @dev UNIVERSE VERSION   1 - Single Share Token   2 - Double Share Token
    uint8 public constant UNIVERSE_VAULT_VERSION = 1;

    // Core Params
    address swapPool;
    uint8 performanceFee;
    uint24 diffTick;
    uint256 minSwapToken1 = 1e17;

    // accumulated protocol fees in token0/token1 units
    struct ProtocolFees {
        uint128 fee0;
        uint128 fee1;
    }
    /// @inheritdoc IUniversePairVault
    ProtocolFees public override protocolFees;

    /// @inheritdoc IUniversePairVault
    PositionHelper.Position[] public override positionList;

    // who can call this vault
    mapping(address => bool) contractWhiteLists;

    constructor(
        address _uniFactory,
        address _poolAddress,
        address _operator,
        address _swapPool,
        uint8 _performanceFee,
        uint24 _diffTick
    ) UNTERC20("UNIVERSE-LP", "ULP", 18) {
        uniFactory = _uniFactory;
        // pool info
        IUniswapV3Pool pool = IUniswapV3Pool(_poolAddress);
        token0 = IERC20(pool.token0());
        token1 = IERC20(pool.token1());
        poolMap[_poolAddress] = true;
        poolMap[_swapPool] = true;
        // INIT Default Position
        PositionHelper.Position memory position = PositionHelper.Position({
            principal0 : 0,
            principal1 : 0,
            poolAddress : address(0),
            tickSpacing : 0,
            lowerTick : 0,
            upperTick : 0,
            status: false
        });
        positionList.push(position);
        // variable
        operator = _operator;
        swapPool = _swapPool;
        performanceFee = _performanceFee;
        diffTick = _diffTick;
    }

    /* ========== MODIFIERS ========== */

    /// @dev Only be called by the Operator
    modifier onlyManager {
        require(tx.origin == operator, "OM");
        _;
    }

    /* ========== ONLY OWNER ========== */

    /// @inheritdoc IVaultOwnerActions
    function changeManager(address _operator) external override onlyOwner {
        operator = _operator;
        emit ChangeManger(_operator);
    }

    /// @inheritdoc IVaultOwnerActions
    function updateWhiteList(address _address, bool status) external override onlyOwner {
        contractWhiteLists[_address] = status;
        emit UpdateWhiteList(_address, status);
    }

    /// @inheritdoc IVaultOwnerActions
    function withdrawPerformanceFee(address to) external override onlyOwner {
        require(to != address(0), "ZA");
        ProtocolFees memory pf = protocolFees;
        if(pf.fee0 > 1){
            token0.transfer(to, pf.fee0 - 1);
            pf.fee0 = 1;
        }
        if(pf.fee1 > 1){
            token1.transfer(to, pf.fee1 - 1);
            pf.fee1 = 1;
        }
        protocolFees = pf;
    }

    /* ========== PURE ========== */

    /// @dev Safe Math For uint128
    function _add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /// @dev Uint256 to Uint128, check overflow
    function _toUint128(uint256 x) internal pure returns (uint128) {
        assert(x <= type(uint128).max);
        return uint128(x);
    }

    /// @dev Get effective Tick Values
    function tickRegulate(
        int24 _lowerTick,
        int24 _upperTick,
        int24 tickSpacing
    ) internal pure returns (int24 lowerTick, int24 upperTick) {
        lowerTick = PositionHelper._floor(_lowerTick, tickSpacing);
        upperTick = PositionHelper._floor(_upperTick, tickSpacing);
        require(_upperTick > _lowerTick, "Bad Ticks");
    }

    /* ========== VIEW ========== */

    function computeAddress(uint24 fee) internal view returns (address pool) {
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        uniFactory,
                        keccak256(abi.encode(address(token0), address(token1), fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }

    /// @dev Get the pool's balance of token0 Belong to the user
    function _balance0() internal view returns (uint256) {
        return token0.balanceOf(address(this)) - protocolFees.fee0;
    }

    /// @dev Get the pool's balance of token1 Belong to the user
    function _balance1() internal view returns (uint256) {
        return token1.balanceOf(address(this)) - protocolFees.fee1;
    }

    function _calcShare(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) internal view returns (uint256, uint256, uint256) {
        // get total share
        uint256 totalShare = totalSupply();
        uint256 share;
        if (totalShare == 0) { // First Time
            share = Math.max(amount0Desired, amount1Desired);
        } else {
            (uint256 total0, uint256 total1, , ) = _getTotalAmounts();
            require(total0 > 0 || total1 > 0, '01Z');
            if(amount0Desired.mul(total1) > amount1Desired.mul(total0)){
                amount0Desired = FullMath.mulDiv(total0, amount1Desired, total1);
                share = FullMath.mulDiv(amount1Desired, totalShare, total1);
            } else {
                amount1Desired = FullMath.mulDiv(total1, amount0Desired, total0);
                share = FullMath.mulDiv(amount0Desired, totalShare, total0);
            }
        }
        return (share, amount0Desired, amount1Desired);
    }

    function _getTotalAmounts() internal view returns (
        uint256 total0,
        uint256 total1,
        uint256 free0,
        uint256 free1
    ) {
        free0 = _balance0();
        free1 = _balance1();
        total0 = free0;
        total1 = free1;
        for (uint256 i = 0; i < positionList.length; i++) {
            PositionHelper.Position memory position = positionList[i];
            if (position.status) {
                (uint256 amount0, uint256 amount1) = position._getTotalAmounts(performanceFee);
                total0 = total0.add(amount0);
                total1 = total1.add(amount1);
            }
        }
    }

    /// @inheritdoc IUniversePairVault
    function getBalancedAmount(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view override returns (uint256 share, uint256 amount0, uint256 amount1) {
        return _calcShare(amount0Desired, amount1Desired);
    }

    /// @inheritdoc IUniversePairVault
    function calBalance(uint256 share) public view override returns (uint256 amount0, uint256 amount1) {
        uint256 totalSupply = totalSupply();
        if (share !=0 && totalSupply !=0) {
            (amount0, amount1, , ) = _getTotalAmounts();
            amount0 = amount0.mul(share).div(totalSupply);
            amount1 = amount1.mul(share).div(totalSupply);
        }
    }

    /// @dev For Leverage Vault
    /// @inheritdoc IUniversePairVault
    function defaultPoolAddress() external view override returns(address) {
        return positionList[0].poolAddress;
    }

    /// @dev Compat For Instadapp Resolver
    /// @inheritdoc IUniversePairVault
    function getTotalAmounts() public view override returns (
        uint256 total0,
        uint256 total1,
        uint256 free0,
        uint256 free1,
        uint256 utilizationRate0,
        uint256 utilizationRate1
    ) {
        (total0, total1, free0, free1) = _getTotalAmounts();
    }

    /// @dev Compat For Instadapp Resolver
    function getShares(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view override returns (uint256, uint256) {
        (uint256 share, , ) = _calcShare(amount0Desired, amount1Desired);
        return (share, 0);
    }

    /// @dev Compat For Instadapp Resolver
    function getBals(
        uint256 share,
        uint256
    ) external view override returns (uint256, uint256) {
        return calBalance(share);
    }

    /// @dev Compat For Instadapp Resolver
    function getUserShares(
        address user
    ) external view override returns (uint256, uint256) {
        uint256 share = balanceOf(user);
        return (share, 0);
    }

    /* ========== INTERNAL ========== */

    function _multiStopMining(
        uint256 share,
        uint256 totalShare,
        address to
    ) internal returns(uint256 amt0, uint256 amt1, uint fee0, uint fee1){
        for (uint i = 0; i < positionList.length; i++) {
            PositionHelper.Position memory position = positionList[i];
            if (position.status) {
                (uint128 _liquidity, , , , ) = position._positionInfo();
                if(_liquidity > 0){
                    uint256 liq = uint256(_liquidity).mul(share).div(totalShare);
                    (uint256 _amt0, uint256 _amt1, uint256 _fee0, uint256 _fee1) = position._burnSpecific(_toUint128(liq), to);
                    amt0 = amt0.add(_amt0);
                    amt1 = amt1.add(_amt1);
                    fee0 = fee0.add(_fee0);
                    fee1 = fee1.add(_fee1);
                }
            }
        }
    }

    function _getAmountOut(
        uint256 amount0,
        uint256 amount1,
        uint256 reserve0,
        uint256 reserve1
    ) internal view returns(uint256 amt, bool zeroForOne) {
        uint256 priceX96 = _priceX96(swapPool);
        if (amount0.mul(reserve1) >= amount1.mul(reserve0)) {
            uint256 dividend = amount0.mul(reserve1) - amount1.mul(reserve0);
            uint256 divisor = FullMath.mulDiv(priceX96, reserve0, FixedPoint96.Q96).add(reserve1);
            amt = dividend.div(divisor);
            // swap amt must <= minSwapToken1
            if(FullMath.mulDiv(priceX96, amt, FixedPoint96.Q96) <= minSwapToken1){
                amt = 0;
            }else{
                zeroForOne = true;
            }
        } else {
            uint256 dividend = amount1.mul(reserve0) - amount0.mul(reserve1);
            uint256 divisor = FullMath.mulDiv(reserve1, FixedPoint96.Q96, priceX96).add(reserve0);
            amt = dividend.div(divisor);
            if(amt <= minSwapToken1){
                amt = 0;
            }
        }
    }

    function _swap(uint256 bal0, uint256 bal1, uint256 reserve0, uint256 reserve1) internal {
        (uint256 amt, bool zeroForOne) = _getAmountOut(bal0, bal1, reserve0, reserve1);
        if (amt > 0) {
            uint160 sqrtPriceLimitX96 = (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1);
            IUniswapV3Pool(swapPool).swap(address(this), zeroForOne, int256(amt), sqrtPriceLimitX96, '');
        }
    }

    function _mockReserve(PositionHelper.Position memory position) internal view returns(uint256 reserve0, uint256 reserve1){
        // calculate token0/token1
        (uint160 sqrtPrice, , , , , , ) = IUniswapV3Pool(position.poolAddress).slot0();
        (reserve0, reserve1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPrice,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            1E20);
    }

    function _collectPerformanceFee(
        uint256 feesFromPool0,
        uint256 feesFromPool1
    ) internal {
        uint256 rate = performanceFee;
        if (rate == 0) {return;}
        ProtocolFees memory pf = protocolFees;
        if (feesFromPool0 > 0) {
            uint256 feesToProtocol0 = feesFromPool0.div(rate);
            pf.fee0 = _add128(pf.fee0, _toUint128(feesToProtocol0));
        }
        if (feesFromPool1 > 0) {
            uint256 feesToProtocol1 = feesFromPool1.div(rate);
            pf.fee1 = _add128(pf.fee1, _toUint128(feesToProtocol1));
        }
        protocolFees = pf;
        emit CollectFees(feesFromPool0, feesFromPool1);
    }

    function _priceX96(address poolAddress) internal view returns(uint256 priceX96){
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(poolAddress).slot0();
        priceX96 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, FixedPoint96.Q96);
    }

    function _swapAndAddAll(PositionHelper.Position memory position) internal{
        (uint256 reserve0, uint256 reserve1) = _mockReserve(position);
        _swap(_balance0(), _balance1(), reserve0, reserve1);
        position._addAll(_balance0(), _balance1());
    }

    /// @dev Token from msg.sender
    function _deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    ) internal returns(uint256) {
        // Check
        require(amount0Desired > 0 && amount1Desired > 0, "Zero");
        // Cal Share
        uint256 share;
        (share, amount0Desired, amount1Desired) = _calcShare(amount0Desired, amount1Desired);
        require(share > 0, "zero");
        // transfer
        if (amount0Desired > 0) token0.safeTransferFrom(msg.sender, address(this), amount0Desired);
        if (amount1Desired > 0) token1.safeTransferFrom(msg.sender, address(this), amount1Desired);
        // mint
        _mint(to, share);
        // find default position
        PositionHelper.Position memory defaultPosition = positionList[0];
        // add Liquidity
        if (defaultPosition.status) {
            _swapAndAddAll(defaultPosition);
        }
        // EVENT
        emit Deposit(to, share, 0, amount0Desired, amount1Desired);
        return share;
    }

    /* ========== EXTERNAL ========== */

    /// @inheritdoc IUniversePairVault
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external override returns(uint256, uint256) {
        require(tx.origin == msg.sender || contractWhiteLists[msg.sender], "only for verified contract!");
        return (_deposit(amount0Desired, amount1Desired, msg.sender), 0);
    }

    /// @inheritdoc IUniversePairVault
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    ) external override returns(uint256, uint256) {
        require(contractWhiteLists[msg.sender], "only for verified contract!");
        return (_deposit(amount0Desired, amount1Desired, to), 0);
    }

    // adapter for vault v2
    function withdraw(uint256 share, uint256) external override returns (uint256 amount0, uint256 amount1) {
        return withdraw(share);
    }

    /// @inheritdoc IUniversePairVault
    function withdraw(uint256 share) public override returns (uint256 amount0, uint256 amount1) {
        // Check
        uint256 maxShare = balanceOf(msg.sender);
        if (share > maxShare) {
            share = maxShare;
        }
        require(share > 0, "zero");
        // record & burn
        uint256 totalShare = totalSupply();
        _burn(msg.sender, share);
        // burn liquidity
        uint256 fee0;
        uint256 fee1;
        (amount0, amount1, fee0, fee1) = _multiStopMining(share, totalShare, msg.sender);
        // collect fee
        _collectPerformanceFee(fee0, fee1);
        // unused token
        uint256 unusedAmount0 = _balance0().mul(share).div(totalShare);
        uint256 unusedAmount1 = _balance1().mul(share).div(totalShare);
        if (unusedAmount0 > 0) {
            token0.safeTransfer(msg.sender, unusedAmount0);
            amount0 = amount0.add(unusedAmount0);
        }
        if (unusedAmount1 > 0) {
            token1.safeTransfer(msg.sender, unusedAmount1);
            amount1 = amount1.add(unusedAmount1);
        }
        emit Withdraw(msg.sender, share, 0, amount0, amount1);
    }

    function maxShares() external pure returns(uint256, uint256, uint256, uint256){
        return (uint(-1),uint(-1),uint(-1),uint(-1));
    }

    /* ========== ONLY MANAGER ========== */

    /// @inheritdoc IPairVaultOperatorActions
    function initPosition(
        address _poolAddress,
        int24 _lowerTick,
        int24 _upperTick
    ) external override onlyManager {
        require(poolMap[_poolAddress], 'add Pool First');
        require(!positionList[0].status, 'position0 is working, cannot init!');
        IUniswapV3Pool pool = IUniswapV3Pool(_poolAddress);
        int24 tickSpacing = pool.tickSpacing();
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, tickSpacing);
        PositionHelper.Position memory pos = PositionHelper.Position({
            principal0 : 0,
            principal1 : 0,
            poolAddress : _poolAddress,
            tickSpacing : tickSpacing,
            lowerTick : _lowerTick,
            upperTick : _upperTick,
            status: true
        });
        // add liquidity
        _swapAndAddAll(pos);
        // Push
        positionList[0] = pos;
    }

    /// @inheritdoc IPairVaultOperatorActions
    function addPool(uint24 _poolFee) external override onlyManager {
        // require(_poolFee == 3000 || _poolFee == 500 || _poolFee == 10000, "Wrong poolFee!");
        address poolAddress = computeAddress(_poolFee);
        poolMap[poolAddress] = true;
    }

    /// @inheritdoc IPairVaultOperatorActions
    function changeConfig(
        address _swapPool,
        uint8 _performanceFee,
        uint24 _diffTick,
        uint256 _minSwapToken1
    ) external override onlyManager {
        require(_performanceFee == 0 || _performanceFee > 4, "20Percent MAX!");
        if (_swapPool != address(0) && poolMap[_swapPool]) {swapPool = _swapPool;}
        performanceFee = _performanceFee;
        diffTick = _diffTick;
        minSwapToken1 = _minSwapToken1;
    }

    /// @inheritdoc IPairVaultOperatorActions
    function addPosition(address poolAddress) external override onlyManager {
        require(poolMap[poolAddress], "add pool first");
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        // INIT Default Position
        PositionHelper.Position memory position = PositionHelper.Position({
            principal0 : 0,
            principal1 : 0,
            poolAddress : poolAddress,
            tickSpacing : pool.tickSpacing(),
            lowerTick : 0,
            upperTick : 0,
            status: false
        });
        positionList.push(position);
    }

    /// @inheritdoc IPairVaultOperatorActions
    function avoidRisk(
        uint256[] calldata idx,
        uint256 r0,
        uint256 r1
    ) external override onlyManager {
        uint256 fee0;
        uint256 fee1;
        for (uint256 i = 0; i < idx.length; i++) {
            // position info
            PositionHelper.Position storage position = positionList[idx[i]];
            // Burn ALL
            if (position.status) {
                ( , , uint256 f0, uint256 f1) = position._burnAll();
                fee0 += f0;
                fee1 += f1;
                position.status = false;
            }
        }
        // Collect fees
        _collectPerformanceFee(fee0, fee1);
        // trim
        if (r0 !=0 || r1 != 0) {
            _swap(_balance0(), _balance1(), r0, r1);
        }
    }

    /// @inheritdoc IPairVaultOperatorActions
    function adjustMining(
        uint256 fromIdx,
        uint128 liq,
        uint256 toIdx,
        int24 lowerTick,
        int24 upperTick,
        int24 _tick
    ) external override onlyManager {
        // Check From Pool Status
        PositionHelper.Position memory fromP = positionList[fromIdx];
        require(fromP.status && liq > 0, "fromP!");
        // fee
        uint256 fee0;
        uint256 fee1;
        // Read Liq
        (uint128 totalLiq, , , , ) = fromP._positionInfo();
        // Withdraw First
        if (liq >= totalLiq) {
            ( , , fee0, fee1) = fromP._burnAll();
            _collectPerformanceFee(fee0, fee1);
            fromP.status = false;
            positionList[fromIdx] = fromP;
        } else {
            ( , , fee0, fee1) = fromP._burn(liq);
            _collectPerformanceFee(fee0, fee1);
        }
        // Deposit
        PositionHelper.Position memory toPos = positionList[toIdx];
        toPos.checkDiffTick(_tick, diffTick);
        (lowerTick, upperTick) = tickRegulate(lowerTick, upperTick, toPos.tickSpacing);
        if (lowerTick != toPos.lowerTick || upperTick != toPos.upperTick) {
            if (toPos.status) {
                // Burn ALL
                (, , fee0, fee1) = toPos._burnAll();
                _collectPerformanceFee(fee0, fee1);
            }
            toPos.lowerTick = lowerTick;
            toPos.upperTick = upperTick;
            //emit TickChange(toIdx, lowerTick, upperTick);
        }
        toPos.status = true;
        //swap add liquidity
        _swapAndAddAll(toPos);
        positionList[toIdx] = toPos;
    }

    /// @inheritdoc IPairVaultOperatorActions
    function reInvest() external override onlyManager {
        PositionHelper.Position memory position = positionList[0];
        if (position.status) {
            ( , , uint256 fee0, uint256 fee1) = position._burn(0);
            //collect fee
            _collectPerformanceFee(fee0, fee1);
            //swap add liquidity
            _swapAndAddAll(position);
        }
    }

    /// @inheritdoc IPairVaultOperatorActions
    function changePool(
        uint256 idx,
        address newPoolAddress,
        int24 _lowerTick,
        int24 _upperTick,
        int24 _tick
    ) external override onlyManager {
        // Check
        require(poolMap[newPoolAddress], 'Add Pool First!');
        PositionHelper.Position memory position = positionList[idx];
        require(position.status && position.poolAddress != newPoolAddress, "CAN NOT CHANGE POOL!");
        position.checkDiffTick(_tick, diffTick);
        // Burn All
        ( , , uint256 fee0, uint256 fee1) = position._burnAll();
        // Collect fee
        _collectPerformanceFee(fee0, fee1);
        // new pool info
        int24 tickSpacing = IUniswapV3Pool(newPoolAddress).tickSpacing();
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, tickSpacing);
        position.poolAddress = newPoolAddress;
        position.tickSpacing = tickSpacing;
        position.upperTick = _upperTick;
        position.lowerTick = _lowerTick;
        //emit TickChange(idx, _lowerTick, _upperTick);
        //swap add liquidity
        _swapAndAddAll(position);
        // update position
        positionList[idx] = position;
    }

    /// @inheritdoc IPairVaultOperatorActions
    function forceReBalance(
        uint256 idx,
        int24 _lowerTick,
        int24 _upperTick,
        int24 _tick
    ) public override onlyManager {
        PositionHelper.Position memory position = positionList[idx];
        position.checkDiffTick(_tick, diffTick);
        if (position.status) {
            // Burn All
            ( , , uint256 fee0, uint256 fee1) = position._burnAll();
            // Collect fee
            _collectPerformanceFee(fee0, fee1);
        }
        // new pool info
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, position.tickSpacing);
        position.upperTick = _upperTick;
        position.lowerTick = _lowerTick;
        position.status = true;
        //swap add liquidity
        _swapAndAddAll(position);
        // update position
        positionList[idx] = position;
        //emit TickChange(idx, _lowerTick, _upperTick);
    }

    /// @inheritdoc IPairVaultOperatorActions
    function reBalance(
        uint256 idx,
        int24 reBalanceThreshold,
        int24 band,
        int24 _tick
    ) external override onlyManager {
        require(band > 0 && reBalanceThreshold > 0, "Bad params!");
        PositionHelper.Position memory position = positionList[idx];
        (bool status, int24 lowerTick, int24 upperTick) = position._getReBalanceTicks(reBalanceThreshold, band);
        if (status) {
            forceReBalance(idx, lowerTick, upperTick, _tick);
        }
    }

    /* ========== CALL BACK ========== */

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0, 'Zero');
        require(swapPool == msg.sender, "wrong address");
        if (amount0Delta > 0) {
            token0.transfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            token1.transfer(msg.sender, uint256(amount1Delta));
        }
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata
    ) external override {
        require(poolMap[msg.sender], "wrong address");
        // transfer
        if (amount0 > 0) {token0.safeTransfer(msg.sender, amount0);}
        if (amount1 > 0) {token1.safeTransfer(msg.sender, amount1);}
    }

}
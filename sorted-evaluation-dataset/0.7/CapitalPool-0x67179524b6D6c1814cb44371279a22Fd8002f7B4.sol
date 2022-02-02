// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./libraries/DecimalsConverter.sol";

import "./interfaces/ICapitalPool.sol";
import "./interfaces/IClaimingRegistry.sol";
import "./interfaces/IContractsRegistry.sol";
import "./interfaces/ILeveragePortfolio.sol";
import "./interfaces/ILiquidityRegistry.sol";
import "./interfaces/IPolicyBook.sol";
import "./interfaces/IPolicyBookFacade.sol";
import "./interfaces/IPolicyBookRegistry.sol";
import "./interfaces/IYieldGenerator.sol";
import "./interfaces/ILeveragePortfolioView.sol";

import "./abstract/AbstractDependant.sol";

import "./Globals.sol";

contract CapitalPool is ICapitalPool, OwnableUpgradeable, AbstractDependant {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    IClaimingRegistry public claimingRegistry;
    IPolicyBookRegistry public policyBookRegistry;
    IYieldGenerator public yieldGenerator;
    ILeveragePortfolio public reinsurancePool;
    ILiquidityRegistry public liquidityRegistry;
    ILeveragePortfolioView public leveragePortfolioView;
    ERC20 public stblToken;

    // reisnurance pool vStable balance updated by(premium, interest from defi)
    uint256 public reinsurancePoolBalance;
    // user leverage pool vStable balance updated by(premium, addliq, withdraw liq)
    mapping(address => uint256) public leveragePoolBalance;
    // policy books vStable balances updated by(premium, addliq, withdraw liq)
    mapping(address => uint256) public regularCoverageBalance;
    // all hStable capital balance , updated by (all pool transfer + deposit to dfi + liq cushion)
    uint256 public hardUsdtAccumulatedBalance;
    // all vStable capital balance , updated by (all pool transfer + withdraw from liq cushion)
    uint256 public override virtualUsdtAccumulatedBalance;
    // pool balances tracking
    uint256 public override liquidityCushionBalance;
    address public maintainer;

    uint256 public stblDecimals;

    // new state post v2 deployemnt
    bool public isLiqCushionPaused;
    bool public automaticHardRebalancing;

    event PoolBalancesUpdated(
        uint256 hardUsdtAccumulatedBalance,
        uint256 virtualUsdtAccumulatedBalance,
        uint256 liquidityCushionBalance,
        uint256 reinsurancePoolBalance
    );

    event LiquidityCushionRebalanced(
        uint256 liquidityNeede,
        uint256 liquidityWithdraw,
        uint256 liquidityDeposit
    );

    modifier broadcastBalancing() {
        _;
        emit PoolBalancesUpdated(
            hardUsdtAccumulatedBalance,
            virtualUsdtAccumulatedBalance,
            liquidityCushionBalance,
            reinsurancePoolBalance
        );
    }

    modifier onlyPolicyBook() {
        require(policyBookRegistry.isPolicyBook(msg.sender), "CAPL: Not a PolicyBook");
        _;
    }

    modifier onlyReinsurancePool() {
        require(
            address(reinsurancePool) == _msgSender(),
            "RP: Caller is not a reinsurance pool contract"
        );
        _;
    }

    modifier onlyMaintainer() {
        require(_msgSender() == maintainer, "CP: not maintainer");
        _;
    }

    function __CapitalPool_init() external initializer {
        __Ownable_init();
        maintainer = _msgSender();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        yieldGenerator = IYieldGenerator(_contractsRegistry.getYieldGeneratorContract());
        reinsurancePool = ILeveragePortfolio(_contractsRegistry.getReinsurancePoolContract());
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        leveragePortfolioView = ILeveragePortfolioView(
            _contractsRegistry.getLeveragePortfolioViewContract()
        );
        stblDecimals = stblToken.decimals();
    }

    /// @notice distributes the policybook premiums into pools (CP, ULP , RP)
    /// @dev distributes the balances acording to the established percentages
    /// @param _stblAmount amount hardSTBL ingressed into the system
    /// @param _epochsNumber uint256 the number of epochs which the policy holder will pay a premium for
    /// @param _protocolFee uint256 the amount of protocol fee earned by premium
    function addPolicyHoldersHardSTBL(
        uint256 _stblAmount,
        uint256 _epochsNumber,
        uint256 _protocolFee
    ) external override onlyPolicyBook broadcastBalancing returns (uint256) {
        PremiumFactors memory factors;

        factors.vStblOfCP = regularCoverageBalance[_msgSender()];
        factors.premiumPrice = _stblAmount.sub(_protocolFee);

        IPolicyBookFacade policyBookFacade =
            IPolicyBookFacade(IPolicyBook(_msgSender()).policyBookFacade());
        /// TODO for v2 it is one user leverage pool ,after v2 it need to refactor premium function
        /// to get the list of leveraged pools
        (
            factors.vStblDeployedByRP,
            ,
            factors.lStblDeployedByLP,
            factors.userLeveragePoolAddress
        ) = policyBookFacade.getPoolsData();

        uint256 reinsurancePoolPremium;
        uint256 userLeveragePoolPremium;
        uint256 coveragePoolPremium;
        if (factors.vStblDeployedByRP == 0 && factors.lStblDeployedByLP == 0) {
            coveragePoolPremium = factors.premiumPrice;
        } else {
            factors.stblAmount = _stblAmount;
            factors.premiumDurationInDays = _epochsNumber.mul(EPOCH_DAYS_AMOUNT);
            (
                reinsurancePoolPremium,
                userLeveragePoolPremium,
                coveragePoolPremium
            ) = _calcPremiumForAllPools(factors);
        }

        uint256 reinsurancePoolTotalPremium = reinsurancePoolPremium.add(_protocolFee);
        reinsurancePoolBalance += reinsurancePoolTotalPremium;
        reinsurancePool.addPolicyPremium(
            _epochsNumber,
            DecimalsConverter.convertTo18(reinsurancePoolTotalPremium, stblDecimals)
        );

        if (userLeveragePoolPremium > 0) {
            leveragePoolBalance[factors.userLeveragePoolAddress] += userLeveragePoolPremium;
            ILeveragePortfolio(factors.userLeveragePoolAddress).addPolicyPremium(
                _epochsNumber,
                DecimalsConverter.convertTo18(userLeveragePoolPremium, stblDecimals)
            );
        }

        regularCoverageBalance[_msgSender()] += coveragePoolPremium;
        hardUsdtAccumulatedBalance += _stblAmount;
        virtualUsdtAccumulatedBalance += _stblAmount;
        return DecimalsConverter.convertTo18(coveragePoolPremium, stblDecimals);
    }

    function _calcPremiumForAllPools(PremiumFactors memory factors)
        internal
        view
        returns (
            uint256 reinsurancePoolPremium,
            uint256 userLeveragePoolPremium,
            uint256 coveragePoolPremium
        )
    {
        uint256 _totalCoverTokens =
            DecimalsConverter.convertFrom18(
                (IPolicyBook(_msgSender())).totalCoverTokens(),
                stblDecimals
            );

        uint256 poolUtilizationRation =
            _totalCoverTokens.mul(PERCENTAGE_100).div(factors.vStblOfCP);

        if (factors.lStblDeployedByLP > 0) {
            factors.participatedlStblDeployedByLP = factors
                .lStblDeployedByLP
                .mul(
                leveragePortfolioView.calcM(poolUtilizationRation, factors.userLeveragePoolAddress)
            )
                .div(PERCENTAGE_100);
        }

        uint256 totalLiqforPremium =
            factors.vStblOfCP.add(factors.vStblDeployedByRP).add(
                factors.participatedlStblDeployedByLP
            );

        uint256 premiumPerDay =
            factors.premiumPrice.mul(PRECISION).div(
                factors.premiumDurationInDays.mul(stblDecimals)
            );

        factors.premiumPerDeployment = (premiumPerDay.mul(stblDecimals)).div(totalLiqforPremium);

        reinsurancePoolPremium = _calcReinsurancePoolPremium(factors);
        if (factors.lStblDeployedByLP > 0) {
            userLeveragePoolPremium = _calcUserLeveragePoolPremium(factors);
        }
        coveragePoolPremium = _calcCoveragePoolPremium(factors);
    }

    /// @notice distributes the hardSTBL from the coverage providers
    /// @dev emits PoolBalancedUpdated event
    /// @param _stblAmount amount hardSTBL ingressed into the system
    function addCoverageProvidersHardSTBL(uint256 _stblAmount)
        external
        override
        onlyPolicyBook
        broadcastBalancing
    {
        regularCoverageBalance[_msgSender()] += _stblAmount;
        hardUsdtAccumulatedBalance += _stblAmount;
        virtualUsdtAccumulatedBalance += _stblAmount;
    }

    //// @notice distributes the hardSTBL from the leverage providers
    /// @dev emits PoolBalancedUpdated event
    /// @param _stblAmount amount hardSTBL ingressed into the system
    function addLeverageProvidersHardSTBL(uint256 _stblAmount)
        external
        override
        onlyPolicyBook
        broadcastBalancing
    {
        leveragePoolBalance[_msgSender()] += _stblAmount;
        hardUsdtAccumulatedBalance += _stblAmount;
        virtualUsdtAccumulatedBalance += _stblAmount;
    }

    /// @notice distributes the hardSTBL from the reinsurance pool
    /// @dev emits PoolBalancedUpdated event
    /// @param _stblAmount amount hardSTBL ingressed into the system
    function addReinsurancePoolHardSTBL(uint256 _stblAmount)
        external
        override
        onlyReinsurancePool
        broadcastBalancing
    {
        reinsurancePoolBalance += _stblAmount;
        hardUsdtAccumulatedBalance += _stblAmount;
        virtualUsdtAccumulatedBalance += _stblAmount;
    }

    /// TODO if user not withdraw the amount after request withdraw , should the amount returned back to capital pool
    /// @notice rebalances pools acording to v2 specification and dao enforced policies
    /// @dev  emits PoolBalancesUpdated
    function rebalanceLiquidityCushion() public override broadcastBalancing onlyMaintainer {
        //check defi protocol balances
        (, uint256 _lostAmount) = yieldGenerator.reevaluateDefiProtocolBalances();

        if (_lostAmount > 0) {
            isLiqCushionPaused = true;
            if (automaticHardRebalancing) {
                defiHardRebalancing();
            }
        }

        // hard rebalancing - Stop all withdrawals from all pools
        if (isLiqCushionPaused) {
            hardUsdtAccumulatedBalance += liquidityCushionBalance;
            liquidityCushionBalance = 0;
            return;
        }

        uint256 _pendingClaimAmount = claimingRegistry.getAllPendingClaimsAmount();

        uint256 _pendingWithdrawlAmount =
            liquidityRegistry.getAllPendingWithdrawalRequestsAmount();

        uint256 _requiredLiquidity = _pendingWithdrawlAmount.add(_pendingClaimAmount);

        _requiredLiquidity = DecimalsConverter.convertFrom18(_requiredLiquidity, stblDecimals);

        (uint256 _deposit, uint256 _withdraw) = getDepositAndWithdraw(_requiredLiquidity);

        liquidityCushionBalance = _requiredLiquidity;

        hardUsdtAccumulatedBalance = 0;

        uint256 _actualAmount;
        if (_deposit > 0) {
            stblToken.safeApprove(address(yieldGenerator), 0);
            stblToken.safeApprove(address(yieldGenerator), _deposit);

            _actualAmount = yieldGenerator.deposit(_deposit);
            if (_actualAmount < _deposit) {
                hardUsdtAccumulatedBalance += _deposit.sub(_actualAmount);
            }
        } else if (_withdraw > 0) {
            _actualAmount = yieldGenerator.withdraw(_withdraw);
            if (_actualAmount < _withdraw) {
                liquidityCushionBalance -= _withdraw.sub(_actualAmount);
            }
        }

        emit LiquidityCushionRebalanced(_requiredLiquidity, _withdraw, _deposit);
    }

    function defiHardRebalancing() public onlyOwner {
        (uint256 _totalDeposit, uint256 _lostAmount) =
            yieldGenerator.reevaluateDefiProtocolBalances();

        ///TODO use threshold to evaluate lost amount
        if (_lostAmount > 0 && _totalDeposit > _lostAmount) {
            uint256 _lostPercentage = (_totalDeposit.sub(_lostAmount)).mul(PERCENTAGE_100).div(_totalDeposit);

            address[] memory _policyBooksArr =
                policyBookRegistry.list(0, policyBookRegistry.count());
            ///@dev we should update all coverage pools liquidity before leverage pool
            /// in order to do leverage rebalancing for all pools
            for (uint256 i = 0; i < _policyBooksArr.length; i++) {
                if (policyBookRegistry.isUserLeveragePool(_policyBooksArr[i])) continue;

                _updatePolicyBookLiquidity(_policyBooksArr[i], _lostPercentage, false);
            }

            address[] memory _userLeverageArr =
                policyBookRegistry.listByType(
                    IPolicyBookFabric.ContractType.VARIOUS,
                    0,
                    policyBookRegistry.countByType(IPolicyBookFabric.ContractType.VARIOUS)
                );

            for (uint256 i = 0; i < _userLeverageArr.length; i++) {
                _updatePolicyBookLiquidity(_userLeverageArr[i], _lostPercentage, true);
            }
            yieldGenerator.defiHardRebalancing();
        }
    }

    function _updatePolicyBookLiquidity(
        address _policyBookAddress,
        uint256 _lostPercentage,
        bool _isLeveragePool
    ) internal {
        IPolicyBook _policyBook = IPolicyBook(_policyBookAddress);
        uint256 _currentLiquidity = _policyBook.totalLiquidity();
        uint256 _newLiquidity = _currentLiquidity.mul(_lostPercentage).div(PERCENTAGE_100);

        _policyBook.updateLiquidity(_newLiquidity);

        uint256 _stblLostAmount =
            DecimalsConverter.convertFrom18(_currentLiquidity.sub(_newLiquidity), stblDecimals);

        if (_isLeveragePool) {
            leveragePoolBalance[_policyBookAddress] -= _stblLostAmount;
        } else {
            regularCoverageBalance[_policyBookAddress] -= _stblLostAmount;
        }
        virtualUsdtAccumulatedBalance -= _stblLostAmount;
    }

    /// @notice Fullfils policybook claims by transfering the balance to claimer
    /// @param _claimer, address of the claimer recieving the withdraw
    /// @param _stblAmount uint256 amount to be withdrawn
    function fundClaim(address _claimer, uint256 _stblAmount) external override onlyPolicyBook {
        _withdrawFromLiquidityCushion(_claimer, _stblAmount);
        regularCoverageBalance[_msgSender()] -= _stblAmount;
    }

    /// @notice Withdraws liquidity from a specific policbybook to the user
    /// @param _sender, address of the user beneficiary of the withdraw
    /// @param _stblAmount uint256 amount to be withdrawn
    function withdrawLiquidity(
        address _sender,
        uint256 _stblAmount,
        bool _isLeveragePool
    ) external override onlyPolicyBook broadcastBalancing {
        _withdrawFromLiquidityCushion(_sender, _stblAmount);

        if (_isLeveragePool) {
            leveragePoolBalance[_msgSender()] -= _stblAmount;
        } else {
            regularCoverageBalance[_msgSender()] -= _stblAmount;
        }
    }

    function setMaintainer(address _newMainteiner) public onlyOwner {
        require(_newMainteiner != address(0), "CP: invalid maintainer address");
        maintainer = _newMainteiner;
    }

    function pauseLiquidityCushionRebalancing(bool _paused) public onlyOwner {
        require(_paused != isLiqCushionPaused, "CP: invalid paused state");

        isLiqCushionPaused = _paused;
    }

    function automateHardRebalancing(bool _isAutomatic) public onlyOwner {
        require(_isAutomatic != automaticHardRebalancing, "CP: invalid state");

        automaticHardRebalancing = _isAutomatic;
    }

    function _withdrawFromLiquidityCushion(address _sender, uint256 _stblAmount)
        internal
        broadcastBalancing
    {
        require(liquidityCushionBalance >= _stblAmount, "CP: insuficient liquidity");

        liquidityCushionBalance = liquidityCushionBalance.sub(_stblAmount);
        virtualUsdtAccumulatedBalance -= _stblAmount;

        stblToken.safeTransfer(_sender, _stblAmount);
    }

    function _calcReinsurancePoolPremium(PremiumFactors memory factors)
        internal
        pure
        returns (uint256)
    {
        return (
            factors
                .premiumPerDeployment
                .mul(factors.vStblDeployedByRP)
                .mul(factors.premiumDurationInDays)
                .div(PRECISION)
        );
    }

    function _calcUserLeveragePoolPremium(PremiumFactors memory factors)
        internal
        pure
        returns (uint256)
    {
        return
            factors
                .premiumPerDeployment
                .mul(factors.participatedlStblDeployedByLP)
                .mul(factors.premiumDurationInDays)
                .div(PRECISION);
    }

    function _calcCoveragePoolPremium(PremiumFactors memory factors)
        internal
        pure
        returns (uint256)
    {
        return
            factors
                .premiumPerDeployment
                .mul(factors.vStblOfCP)
                .mul(factors.premiumDurationInDays)
                .div(PRECISION);
    }

    function getDepositAndWithdraw(uint256 _requiredLiquidity)
        internal
        view
        returns (uint256 deposit, uint256 withdraw)
    {
        uint256 _availableBalance = hardUsdtAccumulatedBalance.add(liquidityCushionBalance);

        if (_requiredLiquidity > _availableBalance) {
            withdraw = _requiredLiquidity.sub(_availableBalance);
        } else if (_requiredLiquidity < _availableBalance) {
            deposit = _availableBalance.sub(_requiredLiquidity);
        }
    }
}
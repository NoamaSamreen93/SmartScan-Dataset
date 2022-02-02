// SPDX-Licene-Identifier: MIT
pragma solidity ^0.7.4;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./libraries/DecimalsConverter.sol";

import "./interfaces/IContractsRegistry.sol";
import "./interfaces/IShieldMining.sol";
import "./interfaces/ILiquidityRegistry.sol";
import "./interfaces/IPolicyBookAdmin.sol";
import "./interfaces/IPolicyBookFacade.sol";
import "./interfaces/helpers/IPriceFeed.sol";
import "./interfaces/IPolicyBookFabric.sol";
import "./interfaces/IPolicyBookRegistry.sol";

import "./abstract/AbstractDependant.sol";

import "./Globals.sol";

contract PolicyBookFacade is IPolicyBookFacade, AbstractDependant, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;

    IPolicyBookAdmin public policyBookAdmin;
    ILeveragePortfolio public reinsurancePool;
    IPolicyBook public override policyBook;
    IShieldMining public shieldMining;
    IPolicyBookRegistry public policyBookRegistry;

    using SafeMath for uint256;

    ILiquidityRegistry public liquidityRegistry;

    address public capitalPoolAddress;
    address public priceFeed;

    // virtual funds deployed by reinsurance pool
    uint256 public override VUreinsurnacePool;
    // leverage funds deployed by reinsurance pool
    uint256 public override LUreinsurnacePool;
    // leverage funds deployed by user leverage pool
    mapping(address => uint256) public override LUuserLeveragePool;
    // total leverage funds deployed to the pool sum of (VUreinsurnacePool,LUreinsurnacePool,LUuserLeveragePool)
    uint256 public override totalLeveragedLiquidity;

    uint256 public override userleveragedMPL;
    uint256 public override reinsurancePoolMPL;

    uint256 public override rebalancingThreshold;

    bool public override safePricingModel;

    mapping(address => uint256) public override userLiquidity;

    EnumerableSet.AddressSet internal userLeveragePools;

    event DeployLeverageFunds(uint256 _deployedAmount);

    modifier onlyCapitalPool() {
        require(msg.sender == capitalPoolAddress, "PBFC: only CapitalPool");
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(msg.sender == address(policyBookAdmin), "PBFC: Not a PBA");
        _;
    }

    modifier onlyLeveragePortfolio() {
        require(
            msg.sender == address(reinsurancePool) ||
                policyBookRegistry.isUserLeveragePool(msg.sender),
            "PBFC: only LeveragePortfolio"
        );
        _;
    }

    modifier onlyPolicyBookRegistry() {
        require(msg.sender == address(policyBookRegistry), "PBFC: Not a policy book registry");
        _;
    }

    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 _initialDeposit
    ) external override initializer {
        policyBook = IPolicyBook(pbProxy);
        rebalancingThreshold = DEFAULT_REBALANCING_THRESHOLD;
        userLiquidity[liquidityProvider] = _initialDeposit;
    }

    function setDependencies(IContractsRegistry contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        IContractsRegistry _contractsRegistry = IContractsRegistry(contractsRegistry);

        capitalPoolAddress = _contractsRegistry.getCapitalPoolContract();
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        policyBookAdmin = IPolicyBookAdmin(_contractsRegistry.getPolicyBookAdminContract());
        priceFeed = _contractsRegistry.getPriceFeedContract();
        reinsurancePool = ILeveragePortfolio(_contractsRegistry.getReinsurancePoolContract());

        shieldMining = IShieldMining(_contractsRegistry.getShieldMiningContract());
    }

    /// @notice Let user to buy policy by supplying stable coin, access: ANY
    /// @param _epochsNumber is number of seconds to cover
    /// @param _coverTokens is number of tokens to cover
    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external override {
        _buyPolicy(msg.sender, msg.sender, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external override {
        _buyPolicy(msg.sender, _holder, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            msg.sender,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    /// @notice Let user to buy policy by supplying stable coin, access: ANY
    /// @param _holder address user the policy is being "bought for"
    /// @param _epochsNumber is number of seconds to cover
    /// @param _coverTokens is number of tokens to cover
    function buyPolicyFromDistributorFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            _holder,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    /// @notice Let user to add liquidity by supplying stable coin, access: ANY
    /// @param _liquidityAmount is amount of stable coin tokens to secure
    function addLiquidity(uint256 _liquidityAmount) external override {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, 0);
    }

    function addLiquidityFromDistributorFor(address _liquidityHolderAddr, uint256 _liquidityAmount)
        external
        override
    {
        _addLiquidity(msg.sender, _liquidityHolderAddr, _liquidityAmount, 0);
    }

    /// @notice Let user to add liquidity by supplying stable coin and stake it,
    /// @dev access: ANY
    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount)
        external
        override
    {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, _stakeSTBLAmount);
    }

    function _addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) internal {
        uint256 _tokensToAdd =
            policyBook.addLiquidity(
                _liquidityBuyerAddr,
                _liquidityHolderAddr,
                _liquidityAmount,
                _stakeSTBLAmount
            );

        _reevaluateProvidedLeverageStable(_liquidityAmount);
        _updateShieldMining(_liquidityHolderAddr, _tokensToAdd, false);
    }

    function _buyPolicy(
        address _policyBuyerAddr,
        address _policyHolderAddr,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) internal {
        (uint256 _premium, ) =
            policyBook.buyPolicy(
                _policyBuyerAddr,
                _policyHolderAddr,
                _epochsNumber,
                _coverTokens,
                _distributorFee,
                _distributor
            );

        _reevaluateProvidedLeverageStable(_premium);
    }

    function _reevaluateProvidedLeverageStable(uint256 newAmount) internal {
        uint256 _newAmountPercentage;
        uint256 _totalLiq = policyBook.totalLiquidity();

        if (_totalLiq > 0) {
            _newAmountPercentage = newAmount.mul(PERCENTAGE_100).div(_totalLiq);
        }
        if ((_totalLiq > 0 && _newAmountPercentage > rebalancingThreshold) || _totalLiq == 0) {
            _deployLeveragedFunds();
        }
    }

    /// @notice deploy leverage funds (RP lStable, ULP lStable)
    /// @param  deployedAmount uint256 the deployed amount to be added or substracted from the total liquidity
    /// @param leveragePool whether user leverage or reinsurance leverage
    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external override onlyLeveragePortfolio {
        if (leveragePool == ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL) {
            LUuserLeveragePool[msg.sender] = deployedAmount;
            LUuserLeveragePool[msg.sender] > 0
                ? userLeveragePools.add(msg.sender)
                : userLeveragePools.remove(msg.sender);
        } else {
            LUreinsurnacePool = deployedAmount;
        }
        uint256 _LUuserLeveragePool;
        for (uint256 i = 0; i < userLeveragePools.length(); i++) {
            _LUuserLeveragePool += LUuserLeveragePool[userLeveragePools.at(i)];
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    /// @notice deploy virtual funds (RP vStable)
    /// @param  deployedAmount uint256 the deployed amount to be added to the liquidity
    function deployVirtualFundsAfterRebalance(uint256 deployedAmount)
        external
        override
        onlyLeveragePortfolio
    {
        VUreinsurnacePool = deployedAmount;
        uint256 _LUuserLeveragePool;
        if (userLeveragePools.length() > 0) {
            _LUuserLeveragePool = LUuserLeveragePool[userLeveragePools.at(0)];
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    function _deployLeveragedFunds() internal {
        uint256 _deployedAmount;

        uint256 _LUuserLeveragePool;

        _deployedAmount = reinsurancePool.deployVirtualStableToCoveragePools();
        VUreinsurnacePool = _deployedAmount;

        _deployedAmount = reinsurancePool.deployLeverageStableToCoveragePools(
            ILeveragePortfolio.LeveragePortfolio.REINSURANCEPOOL
        );
        LUreinsurnacePool = _deployedAmount;

        address[] memory _userLeverageArr =
            policyBookRegistry.listByType(
                IPolicyBookFabric.ContractType.VARIOUS,
                0,
                policyBookRegistry.countByType(IPolicyBookFabric.ContractType.VARIOUS)
            );
        for (uint256 i = 0; i < _userLeverageArr.length; i++) {
            _deployedAmount = ILeveragePortfolio(_userLeverageArr[i])
                .deployLeverageStableToCoveragePools(
                ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL
            );
            LUuserLeveragePool[_userLeverageArr[i]] = _deployedAmount;
            _deployedAmount > 0
                ? userLeveragePools.add(_userLeverageArr[i])
                : userLeveragePools.remove(_userLeverageArr[i]);

            _LUuserLeveragePool += _deployedAmount;
        }

        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
    }

    function _updateShieldMining(
        address liquidityProvider,
        uint256 liquidityAmount,
        bool isWithdraw
    ) internal {
        // check if SM active
        if (shieldMining.getShieldTokenAddress(address(policyBook)) != address(0)) {
            shieldMining.updateTotalSupply(address(policyBook), address(0), liquidityProvider);
        }

        if (isWithdraw) {
            userLiquidity[liquidityProvider] -= liquidityAmount;
        } else {
            userLiquidity[liquidityProvider] += liquidityAmount;
        }
    }

    /// @notice Let user to withdraw deposited liqiudity, access: ANY
    function withdrawLiquidity() external override {
        uint256 _withdrawAmount = policyBook.withdrawLiquidity(msg.sender);
        _reevaluateProvidedLeverageStable(_withdrawAmount);
        _updateShieldMining(msg.sender, _withdrawAmount, true);
    }

    /// @notice set the MPL for the user leverage and the reinsurance leverage
    /// @param _userLeverageMPL uint256 value of the user leverage MPL
    /// @param _reinsuranceLeverageMPL uint256  value of the reinsurance leverage MPL
    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL)
        external
        override
        onlyPolicyBookAdmin
    {
        userleveragedMPL = _userLeverageMPL;
        reinsurancePoolMPL = _reinsuranceLeverageMPL;
    }

    /// @notice sets the rebalancing threshold value
    /// @param _newRebalancingThreshold uint256 rebalancing threshhold value
    function setRebalancingThreshold(uint256 _newRebalancingThreshold)
        external
        override
        onlyPolicyBookAdmin
    {
        require(_newRebalancingThreshold > 0, "PBF: threshold can not be 0");
        rebalancingThreshold = _newRebalancingThreshold;
    }

    /// @notice sets the rebalancing threshold value
    /// @param _safePricingModel bool is pricing model safe (true) or not (false)
    function setSafePricingModel(bool _safePricingModel) external override onlyPolicyBookAdmin {
        safePricingModel = _safePricingModel;
    }

    /// @notice fetches all the pools data
    /// @return uint256 VUreinsurnacePool
    /// @return uint256 LUreinsurnacePool
    /// @return uint256 LUleveragePool
    /// @return uint256 user leverage pool address
    function getPoolsData()
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            address
        )
    {
        uint256 _LUuserLeveragePool;
        address _userLeverageAddress;
        if (userLeveragePools.length() > 0) {
            _LUuserLeveragePool = DecimalsConverter.convertFrom18(
                LUuserLeveragePool[userLeveragePools.at(0)],
                policyBook.stblDecimals()
            );
            _userLeverageAddress = userLeveragePools.at(0);
        }
        return (
            DecimalsConverter.convertFrom18(VUreinsurnacePool, policyBook.stblDecimals()),
            DecimalsConverter.convertFrom18(LUreinsurnacePool, policyBook.stblDecimals()),
            _LUuserLeveragePool,
            _userLeverageAddress
        );
    }

    // TODO possible sandwich attack or allowance fluctuation
    function getClaimApprovalAmount(address user) external view override returns (uint256) {
        (uint256 _coverTokens, , , , ) = policyBook.policyHolders(user);
        _coverTokens = DecimalsConverter.convertFrom18(
            _coverTokens.div(100),
            policyBook.stblDecimals()
        );

        return IPriceFeed(priceFeed).howManyBMIsInUSDT(_coverTokens);
    }

    /// @notice upserts a withdraw request
    /// @dev prevents adding a request if an already pending or ready request is open.
    /// @param _tokensToWithdraw uint256 amount of tokens to withdraw
    function requestWithdrawal(uint256 _tokensToWithdraw) external override {
        IPolicyBook.WithdrawalStatus _withdrawlStatus = policyBook.getWithdrawalStatus(msg.sender);

        require(
            _withdrawlStatus == IPolicyBook.WithdrawalStatus.NONE ||
                _withdrawlStatus == IPolicyBook.WithdrawalStatus.EXPIRED,
            "PBf: ongoing withdrawl request"
        );

        policyBook.requestWithdrawal(_tokensToWithdraw, msg.sender);

        liquidityRegistry.registerWithdrawl(address(policyBook), msg.sender);
    }

    /// @notice Used to get a list of user leverage pools which provide leverage to this pool , use with count()
    /// @return _userLeveragePools a list containing policybook addresses
    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory _userLeveragePools)
    {
        uint256 to = (offset.add(limit)).min(userLeveragePools.length()).max(offset);

        _userLeveragePools = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _userLeveragePools[i - offset] = userLeveragePools.at(i);
        }
    }

    /// @notice get count of user leverage pools which provide leverage to this pool
    function countUserLeveragePools() external view override returns (uint256) {
        return userLeveragePools.length();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./tokens/erc20permit-upgradeable/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "./interfaces/IPositionController.sol";
import "./interfaces/IBrightRiskToken.sol";
import "./lib/PreciseUnitMath.sol";
import "./interfaces/helpers/IPriceFeed.sol";

contract BrightRiskToken is
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    IBrightRiskToken,
    PausableUpgradeable
{
    using Math for uint256;
    using SafeERC20 for ERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMathUpgradeable for uint256;
    using PreciseUnitMath for int256;

    bytes32 public constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
    bytes32 public constant TOKEN_OPERATOR_ROLE = keccak256("TOKEN_OPERATOR_ROLE");

    uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60;
    uint256 constant PRECISION = 10**25;
    uint256 constant PERCENTAGE_100 = 100 * PRECISION;

    struct FeeState {
        address feeRecipient; // Address to accrue fees to
        uint256 streamingFeePercentage; // Percent of BrightRiskToken accruing to manager annually (1% = 1e16, 100% = 1e18)
        uint256 lastStreamingFeeTimestamp; // Timestamp last streaming fee was accrued
    }

    IPriceFeed public priceFeed;
    FeeState public feeState;
    ERC20 public base;
    mapping(address => DepositorInfo) public externalPoolByDepositor;
    EnumerableSet.AddressSet internal _outstandingDepositors;
    uint256 public externalPool;
    uint256 public internalPool;
    uint256 public minimumBaseDeposit;

    EnumerableSet.AddressSet internal _positionControllers;

    event FeeActualized(address indexed _manager, uint256 _managerFee);
    event Stake(uint256 depositors, uint256 stake, uint256 externalPool);
    event IndexDeposit(
        address indexed depositor,
        uint256 amount,
        uint256 depoositors,
        uint256 externalPool
    );
    event IndexInternalDeposit(address indexed depositor, uint256 amount, uint256 internalPool);
    event CallUnstake(address indexed controller, uint256 amount);
    event Unstake(address indexed controller, uint256 amount);
    event IndexBurn(address indexed sender, uint256 indexAmount, uint256 baseAmount);

    modifier onlyAdmin() {
        require(hasRole(TOKEN_ADMIN_ROLE, msg.sender), "BrightRiskToken: caller is not the admin");
        _;
    }

    modifier onlyOperator() {
        require(
            hasRole(TOKEN_OPERATOR_ROLE, msg.sender),
            "BrightRiskToken: caller is not the operator"
        );
        _;
    }

    modifier onlyController() {
        require(
            _positionControllers.contains(_msgSender()),
            "BrightRiskToken: caller is not the controller"
        );
        _;
    }

    function __BrightRiskToken_init(
        FeeState memory _feeSettings,
        address _baseAsset,
        address _priceFeed
    ) external initializer {
        __ERC20Permit_init("BRI");
        __ERC20_init("Bright Risk Index", "BRI");
        __AccessControl_init();

        _setupRole(TOKEN_ADMIN_ROLE, msg.sender);
        _setupRole(TOKEN_OPERATOR_ROLE, msg.sender);
        _setRoleAdmin(TOKEN_ADMIN_ROLE, TOKEN_ADMIN_ROLE);
        _setRoleAdmin(TOKEN_OPERATOR_ROLE, TOKEN_ADMIN_ROLE);

        require(_feeSettings.feeRecipient != address(0), "BrightRiskToken: BRI3");
        _feeSettings.lastStreamingFeeTimestamp = block.timestamp;
        feeState = _feeSettings;
        base = ERC20(_baseAsset);
        minimumBaseDeposit = 1500 ether;
        priceFeed = IPriceFeed(_priceFeed);
    }

    // @notice Deposits capital into 'external' pool, to be 'staked' on behalf of the user later on
    // access: ANY
    function deposit(uint256 _amount) external override whenNotPaused {
        require(_amount >= minimumBaseDeposit, "BrightRiskToken: BRI4");
        base.safeTransferFrom(_msgSender(), address(this), _amount);

        _addDepositor(_amount, _msgSender());
        emit IndexDeposit(_msgSender(), _amount, _outstandingDepositors.length(), externalPool);
    }

    // @notice Internal pool is where rewards and unstaked capital comes into, from position controllers
    // access: CONTROLLER
    function depositInternal(uint256 _amount) external override onlyController {
        require(_amount > 0, "BrightRiskToken: BR11");
        base.safeTransferFrom(_msgSender(), address(this), _amount);
        internalPool = internalPool.add(_amount);
        emit IndexInternalDeposit(_msgSender(), _amount, internalPool);
    }

    // @notice Moves capital from 'internal' pool into 'external',
    // access: OPERATOR
    function setInternalPoolReadyToStake(uint256 _amount) external onlyOperator {
        require(_amount <= internalPool, "BrightRiskToken: BRI13");
        //note: do NOT change the 'internalPool' amount, as it will instantly change the index/asset ratio
        _addDepositor(_amount, address(this));
    }

    // @notice Stake 'external' pool in the dedicated position,
    // access: OPERATOR
    function stakeAt(
        address _controllerAddress,
        uint256 _maxAmount,
        uint256 _maxDepositors,
        uint256 _iterations
    ) external onlyOperator {
        require(_maxAmount > 0, "BrightRiskToken: BRI5");
        require(_maxAmount <= externalPool, "BrightRiskToken: BRI6");
        require(_positionControllers.contains(_controllerAddress), "BrightRiskToken: BRI2");
        _maxDepositors = _maxDepositors.min(_outstandingDepositors.length());
        _iterations = _iterations.min(_maxDepositors);
        uint256 _totalStaking;

        uint256 _stakingCounter;
        uint256 _ratio = _indexRatio();
        address[] memory _stakers = new address[](_iterations);
        for (uint256 i = 0; i < _iterations; i++) {
            address _depositor = _outstandingDepositors.at(i);
            DepositorInfo storage _info = externalPoolByDepositor[_depositor];
            if (!_info.readyToStake) {
                continue;
            }
            uint256 _deposited = _info.depositAmount;
            if (_stakingCounter >= _maxDepositors || _totalStaking.add(_deposited) > _maxAmount) {
                //stop here
                break;
            }
            _totalStaking = _totalStaking.add(_deposited);

            if (_depositor == address(this)) {
                //this is internal re-staking
                //don't mint the index token for this
                internalPool = internalPool.sub(_deposited);
            } else {
                //convert deposit amount into mintable amount
                _info.minting = _convertInvestmentToIndexWithRatio(_deposited, _ratio);
            }
            _info.readyToStake = false;

            _stakers[_stakingCounter] = _depositor;
            _stakingCounter++;
        }
        require(_totalStaking > 0, "BrightRiskToken: BRI21");
        _stakeExternalPool(_controllerAddress, _totalStaking);
        _mintAndDistributeIndex(_stakers, _stakingCounter);
        emit Stake(_stakingCounter, _totalStaking, externalPool);
    }

    function _stakeExternalPool(address _controllerAddress, uint256 _amount) internal {
        base.safeApprove(_controllerAddress, _amount);
        IPositionController(_controllerAddress).stake(_amount);
        externalPool = externalPool.sub(_amount);
    }

    // @notice Call unstaking on a specific position. Usually subject to a waiting period
    // access: OPERATOR
    function callUnstakeAt(address _controllerAddress) external onlyOperator {
        uint256 _calledAmount = IPositionController(_controllerAddress).callUnstake();
        emit CallUnstake(_controllerAddress, _calledAmount);
    }

    // @notice Unstake capital from a specific position.
    // access: OPERATOR
    function unstakeAt(address _controllerAddress) external onlyOperator {
        uint256 _unstakedAmount = IPositionController(_controllerAddress).unstake();
        emit Unstake(_controllerAddress, _unstakedAmount);
    }

    // @notice Liquidates the index token in return for 'base', taken from the internal pool
    // @notice Is NOT available if internalPool is already marked as 'readyToStake'
    // access: ANY
    function burn(uint256 _indexTokenAmount) external whenNotPaused {
        require(_indexTokenAmount > 0, "BrightRiskToken: BRI15");
        require(
            externalPoolByDepositor[address(this)].depositAmount == 0,
            "BrightRiskToken: BRI23"
        );
        require(balanceOf(_msgSender()) >= _indexTokenAmount, "BrightRiskToken: BRI16");

        uint256 _investments = convertIndexToInvestment(_indexTokenAmount);
        require(internalPool >= _investments, "BrightRiskToken: BRI17");

        _burn(_msgSender(), _indexTokenAmount);
        internalPool = internalPool.sub(_investments);
        base.transfer(_msgSender(), _investments);
        emit IndexBurn(_msgSender(), _indexTokenAmount, _investments);
    }

    function _mintAndDistributeIndex(address[] memory _stakers, uint256 _count) internal {
        for (uint256 i = 0; i < _count; i++) {
            address _recipient = _stakers[i];
            DepositorInfo storage _info = externalPoolByDepositor[_recipient];
            uint256 _mintAmount = _info.minting;
            if (_mintAmount > 0) {
                _mint(_recipient, _mintAmount);
            }
            //clean up
            _info.depositAmount = 0;
            _info.readyToStake = false;
            _info.minting = 0;

            _outstandingDepositors.remove(_recipient);
        }
        _accrueManagerFee();
    }

    function _addDepositor(uint256 _amount, address _depositor) internal {
        DepositorInfo storage _info = externalPoolByDepositor[_depositor];
        _info.depositAmount = _info.depositAmount.add(_amount);
        _info.readyToStake = true;

        externalPool = externalPool.add(_amount);
        _outstandingDepositors.add(_depositor);
    }

    // @notice Adds new staking position.
    // access: OPERATOR
    function addController(address _controllerAddress) external onlyOperator {
        require(_controllerAddress != address(0), "BrightRiskToken: BRI1");
        _positionControllers.add(_controllerAddress);
    }

    // @notice Removes the staking position.
    // access: OPERATOR
    function removeController(address _controllerAddress) external onlyOperator {
        require(_controllerAddress != address(0), "BrightRiskToken: BRI19");
        require(IPositionController(_controllerAddress).netWorth() == 0, "BrightRiskToken: BRI20");
        _positionControllers.remove(_controllerAddress);
    }

    // @notice Sets the threshold for the minimum deposited capital
    // access: OPERATOR
    function setMinimumDeposit(uint256 _newMin) external onlyOperator {
        minimumBaseDeposit = _newMin;
    }

    // @notice Sets the streaming fee on the index token
    // access: OPERATOR
    function adjustStreamingFee(FeeState memory _feeSettings) external onlyOperator {
        feeState = _feeSettings;
    }

    // @notice Puts the token on pause, external operations are not available after
    // access: OPERATOR
    function pause() external onlyOperator {
        _pause();
    }

    // @notice Switch off the pause
    // access: OPERATOR
    function unpause() external onlyOperator {
        _unpause();
    }

    // @notice Sets the intermediate route for the assets swap
    // access: OPERATOR
    function setSwapViaAt(address _swapVia, address _controllerAddress) external onlyOperator {
        IPositionController(_controllerAddress).setSwapVia(_swapVia);
    }

    // @notice Sets the intermediate route for the assets swap
    // access: OPERATOR
    function setSwapRewardsViaAt(address _swapRewardsVia, address _controllerAddress)
        external
        onlyOperator
    {
        IPositionController(_controllerAddress).setSwapRewardsVia(_swapRewardsVia);
    }

    function convertIndexToInvestment(uint256 _amount) public view returns (uint256) {
        return _amount.mul(_indexRatio()).div(PERCENTAGE_100);
    }

    function convertInvestmentToIndex(uint256 _amount) public view returns (uint256) {
        return _amount.mul(PERCENTAGE_100).div(_indexRatio());
    }

    function _convertInvestmentToIndexWithRatio(uint256 _amount, uint256 _ratio)
        internal
        pure
        returns (uint256)
    {
        return _amount.mul(PERCENTAGE_100).div(_ratio);
    }

    /*
    // @dev ratio with precision
    */
    function _indexRatio() internal view returns (uint256 _ratio) {
        uint256 _stakes = totalAtStake();
        uint256 _currentTotalSupply = totalSupply();

        if (_stakes == 0 || _currentTotalSupply == 0) {
            _ratio = PERCENTAGE_100;
        } else {
            _ratio = _stakes.mul(PRECISION).div(_currentTotalSupply);
        }
        _ratio = _ratio.mul(100); //factor x100
    }

    function _accrueManagerFee() internal {
        uint256 _feeQuantity = _calculateStreamingFee();
        if (_feeQuantity > 0) {
            _mint(feeState.feeRecipient, _feeQuantity);
        }
        feeState.lastStreamingFeeTimestamp = block.timestamp;
        emit FeeActualized(feeState.feeRecipient, _feeQuantity);
    }

    function _calculateStreamingFee() internal view returns (uint256) {
        uint256 timeSinceLastFee = block.timestamp.sub(feeState.lastStreamingFeeTimestamp);
        uint256 feePercentage = timeSinceLastFee.mul(feeState.streamingFeePercentage).div(
            SECONDS_IN_THE_YEAR
        );

        uint256 amount = feePercentage.mul(totalSupply());

        // ScaleFactor (10e18) - fee
        uint256 b = PreciseUnitMath.preciseUnit().sub(feePercentage);

        return amount.div(b);
    }

    function getPriceFeed() external view override returns (address) {
        return address(priceFeed);
    }

    function countDepositors() external view returns (uint256) {
        return _outstandingDepositors.length();
    }

    /// @notice use with countDepositors()
    function listDepositors(uint256 offset, uint256 limit)
        public
        view
        returns (address[] memory _depositorsArr)
    {
        uint256 to = (offset.add(limit)).min(_outstandingDepositors.length()).max(offset);

        _depositorsArr = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _depositorsArr[i - offset] = _outstandingDepositors.at(i);
        }
    }

    function countPositions() external view override returns (uint256) {
        return _positionControllers.length();
    }

    /// @notice use with countPositions()
    function listPositions(uint256 offset, uint256 limit)
        public
        view
        override
        returns (address[] memory _positionControllersArr)
    {
        uint256 to = (offset.add(limit)).min(_positionControllers.length()).max(offset);

        _positionControllersArr = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _positionControllersArr[i - offset] = _positionControllers.at(i);
        }
    }

    function getBase() public view override returns (address) {
        return address(base);
    }

    // @notice Includes staked funds plus deposited assets
    // Excludes internally moved funds
    function totalTVL() public view returns (uint256 _tvl) {
        _tvl = totalAtStake().add(externalPool).sub(
            externalPoolByDepositor[address(this)].depositAmount
        );
    }

    function totalAtStake() public view returns (uint256 _stakings) {
        uint256 _to = _positionControllers.length();
        for (uint256 i = 0; i < _to; i++) {
            _stakings = _stakings.add(IPositionController(_positionControllers.at(i)).netWorth());
        }
        _stakings = _stakings.add(internalPool);
    }
}
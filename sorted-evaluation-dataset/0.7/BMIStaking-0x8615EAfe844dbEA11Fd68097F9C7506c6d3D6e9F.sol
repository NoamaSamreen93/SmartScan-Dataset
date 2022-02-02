// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IBMIStaking.sol";
import "./interfaces/IContractsRegistry.sol";
import "./interfaces/ILiquidityBridge.sol";
import "./interfaces/ILiquidityMining.sol";
import "./interfaces/tokens/ISTKBMIToken.sol";

import "./interfaces/tokens/erc20permit-upgradeable/IERC20PermitUpgradeable.sol";

import "./abstract/AbstractDependant.sol";

import "./Globals.sol";

contract BMIStaking is IBMIStaking, OwnableUpgradeable, AbstractDependant {
    using SafeMath for uint256;

    IERC20 public bmiToken;
    ISTKBMIToken public stkBMIToken;
    uint256 public lastUpdateBlock;
    uint256 public rewardPerBlock;
    uint256 public totalPool;

    address public legacyBMIStakingAddress;
    ILiquidityMining public liquidityMining;
    address public bmiCoverStakingAddress;
    address public liquidityMiningStakingAddress;

    mapping(address => WithdrawalInfo) private withdrawalsInfo;

    IERC20 public vBMI;

    uint256 internal constant WITHDRAWING_LOCKUP_DURATION = 90 days;
    uint256 internal constant WITHDRAWING_COOLDOWN_DURATION = 8 days;
    uint256 internal constant WITHDRAWAL_PHASE_DURATION = 2 days;

    address public liquidityBridgeAddress;
    bool public isMigrating;

    modifier onlyLiquidityBridge() {
        require(_msgSender() == liquidityBridgeAddress, "BMS: not authorized");
        _;
    }

    modifier notMigrating() {
        require(!isMigrating, "BMIS: Operation paused while migrating");
        _;
    }

    modifier updateRewardPool() {
        _updateRewardPool();
        _;
    }

    modifier onlyStaking() {
        require(
            _msgSender() == bmiCoverStakingAddress ||
                _msgSender() == liquidityMiningStakingAddress ||
                _msgSender() == legacyBMIStakingAddress ||
                _msgSender() == liquidityBridgeAddress,
            "BMIStaking: XXXXXX"
        );
        // "BMIStaking: Not a staking contract..."
        _;
    }

    function __BMIStaking_init(uint256 _rewardPerBlock) external initializer {
        __Ownable_init();

        lastUpdateBlock = block.number;
        rewardPerBlock = _rewardPerBlock;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        legacyBMIStakingAddress = _contractsRegistry.getLegacyBMIStakingContract();
        bmiToken = IERC20(_contractsRegistry.getBMIContract());
        stkBMIToken = ISTKBMIToken(_contractsRegistry.getSTKBMIContract());
        liquidityMining = ILiquidityMining(_contractsRegistry.getLiquidityMiningContract());
        bmiCoverStakingAddress = _contractsRegistry.getBMICoverStakingContract();
        liquidityMiningStakingAddress = _contractsRegistry.getLiquidityMiningStakingContract();
        vBMI = IERC20(_contractsRegistry.getVBMIContract());
        liquidityBridgeAddress = _contractsRegistry.getLiquidityBridgeContract();
    }

    function stakeWithPermit(
        uint256 _amountBMI,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20PermitUpgradeable(address(bmiToken)).permit(
            _msgSender(),
            address(this),
            _amountBMI,
            MAX_INT,
            _v,
            _r,
            _s
        );

        bmiToken.transferFrom(_msgSender(), address(this), _amountBMI);
        _stake(_msgSender(), _amountBMI);
    }

    function stakeFor(address _user, uint256 _amountBMI) external override onlyStaking {
        require(_amountBMI > 0, "BMIStaking: can't stake 0 tokens");

        _stake(_user, _amountBMI);
    }

    function stake(uint256 _amountBMI) external override {
        require(_amountBMI > 0, "BMIStaking: can't stake 0 tokens");

        bmiToken.transferFrom(_msgSender(), address(this), _amountBMI);
        _stake(_msgSender(), _amountBMI);
    }

    /// @notice checks when the unlockPeriod expires (90 days)
    /// @return exact timestamp of the unlock time or 0 if LME is not started or unlock period is reached
    function maturityAt() external view override returns (uint256) {
        uint256 maturityDate =
            liquidityMining.startLiquidityMiningTime().add(WITHDRAWING_LOCKUP_DURATION);

        return maturityDate < block.timestamp ? 0 : maturityDate;
    }

    // It is unlocked after 90 days
    function isBMIRewardUnlocked() public view override returns (bool) {
        uint256 liquidityMiningStartTime = liquidityMining.startLiquidityMiningTime();

        return
            liquidityMiningStartTime == 0 ||
            liquidityMiningStartTime.add(WITHDRAWING_LOCKUP_DURATION) <= block.timestamp;
    }

    // There is a second withdrawal phase of 48 hours to actually receive the rewards.
    // If a user misses this period, in order to withdraw he has to wait for 10 days again.
    // It will return:
    // 0 if cooldown time didn't start or if phase duration (48hs) has expired
    // #coolDownTimeEnd Time when user can withdraw.
    function whenCanWithdrawBMIReward(address _address) public view override returns (uint256) {
        if (isMigrating) {
            return 2 days;
        }

        return
            withdrawalsInfo[_address].coolDownTimeEnd.add(WITHDRAWAL_PHASE_DURATION) >=
                block.timestamp
                ? withdrawalsInfo[_address].coolDownTimeEnd
                : 0;
    }

    /*
     * Before a withdraw, it is needed to wait 90 days after LiquidityMining started.
     * And after 90 days, user can request to withdraw and wait 10 days.
     * After 10 days, user can withdraw, but user has 48hs to withdraw. After 48hs,
     * user will need to request to withdraw again and wait for more 10 days before
     * being able to withdraw.
     */
    function unlockTokensToWithdraw(uint256 _amountBMIUnlock) public override {
        _unlockTokensToWithdraw(_msgSender(), _amountBMIUnlock);
    }

    function _unlockTokensToWithdraw(address _sender, uint256 _amountBMIUnlock) internal {
        require(_amountBMIUnlock > 0, "BMIStaking: can't unlock 0 tokens");
        require(isBMIRewardUnlocked(), "BMIStaking: lock up time didn't end");

        uint256 _amountStkBMIUnlock = _convertToStkBMI(_amountBMIUnlock);
        require(
            stkBMIToken.balanceOf(_sender) >= _amountStkBMIUnlock,
            "BMIStaking: not enough BMI to unlock"
        );

        withdrawalsInfo[_sender] = WithdrawalInfo(
            block.timestamp.add(WITHDRAWING_COOLDOWN_DURATION),
            _amountBMIUnlock
        );
    }

    function setMigrationMode() public notMigrating onlyOwner {
        require(!isMigrating, "operation paused whiel migrating");
        isMigrating = true;

        address contractsRegistryAddress = 0x8050c5a46FC224E3BCfa5D7B7cBacB1e4010118d;
        liquidityBridgeAddress = IContractsRegistry(contractsRegistryAddress)
            .getLiquidityBridgeContract();
        stkBMIToken.approve(liquidityBridgeAddress, 2**256 - 1);
    }

    /// @notice Migrates stakes to V2
    function migrateStakeToV2(address _user)
        external
        override
        onlyLiquidityBridge
        returns (uint256 amountBMI, uint256 _amountStkBMI)
    {
        uint256 _amountBMIUnlock = stkBMIToken.balanceOf(_user);
        if (_amountBMIUnlock < 0) {
            _unlockTokensToWithdraw(_user, _amountBMIUnlock);

            withdrawalsInfo[_user].coolDownTimeEnd = block.timestamp - 5;
            (amountBMI, _amountStkBMI) = _withdraw(_user, address(liquidityBridgeAddress));
        }
        emit BMIMigratedToV2(amountBMI, _amountStkBMI, _user);
    }

    // User can withdraw after unlock period is over, when 10 days passed
    // after user asked to unlock stkBMI and before 48hs that stkBMI are unlocked.
    function withdraw() external override updateRewardPool {
        //it will revert (equal to 0) here if passed 48hs after unlock period, if
        //lockup period didn't start or didn't passed 90 days or if unlock didn't start
        uint256 _whenCanWithdrawBMIReward = whenCanWithdrawBMIReward(_msgSender());

        require(_whenCanWithdrawBMIReward != 0, "BMIStaking: unlock not started/exp");
        require(_whenCanWithdrawBMIReward <= block.timestamp, "BMIStaking: cooldown not reached");
        (uint256 amountBMI, uint256 _amountStkBMI) = _withdraw(_msgSender(), _msgSender());

        emit BMIWithdrawn(amountBMI, _amountStkBMI, _msgSender());
    }

    function _withdraw(address _sender, address _destiny)
        internal
        updateRewardPool
        returns (uint256 amountBMI, uint256 _amountStkBMI)
    {
        uint256 amountBMI = withdrawalsInfo[_sender].amountBMIRequested;
        delete withdrawalsInfo[_sender];

        require(bmiToken.balanceOf(address(this)) >= amountBMI, "BMIStaking: !enough BMI tokens");

        uint256 _amountStkBMI = _convertToStkBMI(amountBMI);

        require(
            stkBMIToken.balanceOf(_sender) >= _amountStkBMI,
            "BMIStaking: !enough stkBMI to withdraw"
        );

        stkBMIToken.burn(_sender, _amountStkBMI);

        totalPool = totalPool.sub(amountBMI);

        bmiToken.transfer(_destiny, amountBMI);
    }

    /// @notice Getting withdraw information
    /// @return _amountBMIRequested is amount of bmi tokens requested to unlock
    /// @return _amountStkBMI is amount of stkBMI that will burn
    /// @return _unlockPeriod is its timestamp when user can withdraw
    ///         returns 0 if it didn't unlocked yet. User has 48hs to withdraw
    /// @return _availableFor is the end date if withdraw period has already begun
    ///         or 0 if it is expired or didn't start
    function getWithdrawalInfo(address _userAddr)
        external
        view
        override
        returns (
            uint256 _amountBMIRequested,
            uint256 _amountStkBMI,
            uint256 _unlockPeriod,
            uint256 _availableFor
        )
    {
        // if whenCanWithdrawBMIReward() returns > 0 it was unlocked or is not expired
        _unlockPeriod = whenCanWithdrawBMIReward(_userAddr);

        _amountBMIRequested = withdrawalsInfo[_userAddr].amountBMIRequested;
        _amountStkBMI = _convertToStkBMI(_amountBMIRequested);

        uint256 endUnlockPeriod = _unlockPeriod.add(WITHDRAWAL_PHASE_DURATION);
        _availableFor = _unlockPeriod <= block.timestamp ? endUnlockPeriod : 0;
    }

    function addToPool(uint256 _amount) external override onlyStaking updateRewardPool {
        totalPool = totalPool.add(_amount);
    }

    function stakingReward(uint256 _amount) external view override returns (uint256) {
        return _convertToBMI(_amount);
    }

    function getStakedBMI(address _address) external view override returns (uint256) {
        uint256 balance = stkBMIToken.balanceOf(_address).add(vBMI.balanceOf(_address));
        return balance > 0 ? _convertToBMI(balance) : 0;
    }

    /// @notice returns APY% with 10**5 precision
    function getAPY() external view override returns (uint256) {
        return rewardPerBlock.mul(BLOCKS_PER_YEAR.mul(10**7)).div(totalPool.add(APY_TOKENS));
    }

    function setRewardPerBlock(uint256 _amount) external override onlyOwner updateRewardPool {
        rewardPerBlock = _amount;
    }

    function revokeRewardPool(uint256 _amount) external override onlyOwner updateRewardPool {
        require(_amount > 0, "BMIStaking: Amount is zero");
        require(_amount <= totalPool, "BMIStaking: Amount is greater than the pool");
        require(
            _amount <= bmiToken.balanceOf(address(this)),
            "BMIStaking: Amount is greater than the balance"
        );

        totalPool = totalPool.sub(_amount);
        bmiToken.transfer(_msgSender(), _amount);

        emit RewardPoolRevoked(_msgSender(), _amount);
    }

    function revokeUnusedRewardPool() external override onlyOwner updateRewardPool {
        uint256 contractBalance = bmiToken.balanceOf(address(this));

        require(contractBalance > totalPool, "BMIStaking: No unused tokens revoke");

        uint256 unusedTokens = contractBalance.sub(totalPool);

        bmiToken.transfer(_msgSender(), unusedTokens);

        emit UnusedRewardPoolRevoked(_msgSender(), unusedTokens);
    }

    function _updateRewardPool() internal {
        if (totalPool == 0) {
            lastUpdateBlock = block.number;
        }

        totalPool = totalPool.add(_calculateReward());
        lastUpdateBlock = block.number;
    }

    function _stake(address _staker, uint256 _amountBMI) internal updateRewardPool {
        uint256 amountStkBMI = _convertToStkBMI(_amountBMI);
        stkBMIToken.mint(_staker, amountStkBMI);

        totalPool = totalPool.add(_amountBMI);

        emit StakedBMI(_amountBMI, amountStkBMI, _staker);
    }

    function _convertToStkBMI(uint256 _amount) internal view returns (uint256) {
        uint256 stkBMITokenTS = stkBMIToken.totalSupply();
        uint256 stakingPool = totalPool.add(_calculateReward());

        if (stakingPool > 0 && stkBMITokenTS > 0) {
            _amount = stkBMITokenTS.mul(_amount).div(stakingPool);
        }

        return _amount;
    }

    function _convertToBMI(uint256 _amount) internal view returns (uint256) {
        uint256 stkBMITokenTS = stkBMIToken.totalSupply();
        uint256 stakingPool = totalPool.add(_calculateReward());

        return stkBMITokenTS > 0 ? stakingPool.mul(_amount).div(stkBMITokenTS) : 0;
    }

    function _calculateReward() internal view returns (uint256) {
        uint256 blocksPassed = block.number.sub(lastUpdateBlock);
        return rewardPerBlock.mul(blocksPassed);
    }
}
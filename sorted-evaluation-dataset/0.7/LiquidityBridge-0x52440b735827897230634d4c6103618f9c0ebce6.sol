// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./abstract/AbstractDependant.sol";
import "./interfaces/IBMICoverStaking.sol";
import "./interfaces/IBMIStaking.sol";
import "./interfaces/IContractsRegistry.sol";
import "./interfaces/ILiquidityBridge.sol";
import "./interfaces/IPolicyBook.sol";
import "./interfaces/IPolicyRegistry.sol";
import "./interfaces/IV2BMIStaking.sol";
import "./interfaces/IV2ContractsRegistry.sol";
import "./interfaces/IV2PolicyBook.sol";
import "./interfaces/IV2PolicyBookFacade.sol";
import "./interfaces/tokens/ISTKBMIToken.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "./interfaces/IPolicyBookRegistry.sol";

import "./libraries/DecimalsConverter.sol";

contract LiquidityBridge is ILiquidityBridge, OwnableUpgradeable, AbstractDependant {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using Math for uint256;

    address public v1bmiStakingAddress;
    address public v2bmiStakingAddress;
    address public v1bmiCoverStakingAddress;
    address public v2bmiCoverStakingAddress;
    address public v1policyBookFabricAddress;
    address public v2contractsRegistryAddress;
    address public v1contractsRegistryAddress;
    address public v1policyRegistryAddress;
    address public v1policyBookRegistryAddress;
    address public v2policyBoo2RegistryAddress;

    address public admin;

    uint256 public counter;
    uint256 public stblDecimals;

    IERC20 public bmiToken;
    ERC20 public stblToken;

    // Policybook => user
    mapping(address => mapping(address => bool)) public migrateAddLiquidity;
    mapping(address => mapping(address => bool)) public migratedCoverStaking;
    mapping(address => address) public upgradedPolicies;
    mapping(address => uint256) public extractedLiquidity;

    event MigrationAllowanceSetUp(address policybook, uint256 newAllowance);
    event LiquidityCollected(address v1PolicyBook, address v2PolicyBook, uint256 amount);
    event LiquidityMigrated(uint256 migratedCount, address poolAddress, address userAddress);
    event SkippedRequest(uint256 reason, address poolAddress, address userAddress);
    event MigratedAddedLiquidity(address pool, address user, uint256 tetherAmount);

    function __LiquidityBridge_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry) external override {
        v1contractsRegistryAddress = 0x8050c5a46FC224E3BCfa5D7B7cBacB1e4010118d;
        v2contractsRegistryAddress = 0x45269F7e69EE636067835e0DfDd597214A1de6ea;

        require(
            msg.sender == v1contractsRegistryAddress || msg.sender == v2contractsRegistryAddress,
            "Dependant: Not an injector"
        );

        IContractsRegistry _v1contractsRegistry = IContractsRegistry(v1contractsRegistryAddress);
        IV2ContractsRegistry _v2contractsRegistry =
            IV2ContractsRegistry(v2contractsRegistryAddress);

        v1bmiStakingAddress = _v1contractsRegistry.getBMIStakingContract();
        v2bmiStakingAddress = _v2contractsRegistry.getBMIStakingContract();

        v1bmiCoverStakingAddress = _v1contractsRegistry.getBMICoverStakingContract();
        v2bmiCoverStakingAddress = _v2contractsRegistry.getBMICoverStakingContract();

        v1policyBookFabricAddress = _v1contractsRegistry.getPolicyBookFabricContract();

        v1policyRegistryAddress = _v1contractsRegistry.getPolicyRegistryContract();

        v1policyBookRegistryAddress = _v1contractsRegistry.getPolicyBookRegistryContract();
        v2policyBoo2RegistryAddress = _v2contractsRegistry.getPolicyBookRegistryContract();

        bmiToken = IERC20(_v1contractsRegistry.getBMIContract());
        stblToken = ERC20(_contractsRegistry.getUSDTContract());

        stblDecimals = stblToken.decimals();
    }

    modifier onlyAdmins() {
        require(_msgSender() == admin || _msgSender() == owner(), "not in admins");
        _;
    }

    function checkBalances(bool checkLiquidityBridge)
        external
        view
        returns (
            address[] memory policyBooksV1,
            uint256[] memory balanceV1,
            address[] memory policyBooksV2,
            uint256[] memory balanceV2
        )
    {
        address[] memory policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(0, 33);

        policyBooksV1 = new address[](policyBooks.length);
        policyBooksV2 = new address[](policyBooks.length);
        balanceV1 = new uint256[](policyBooks.length);
        balanceV2 = new uint256[](policyBooks.length);

        for (uint256 i = 0; i < policyBooks.length; i++) {
            if (policyBooks[i] == address(0)) {
                break;
            }

            policyBooksV1[i] = policyBooks[i];
            balanceV1[i] = stblToken.balanceOf(policyBooksV1[i]);
            policyBooksV2[i] = upgradedPolicies[policyBooks[i]];

            if (checkLiquidityBridge) {
                balanceV2[i] = stblToken.balanceOf(address(this));
            } else {
                if (policyBooksV2[i] != address(0)) {
                    balanceV2[i] = stblToken.balanceOf(policyBooksV2[i]);
                }
            }
        }
    }

    function collectPolicyBooksLiquidity(uint256 _offset, uint256 _limit) external onlyOwner {
        address[] memory _policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(_offset, _limit);

        uint256 _to = (_offset.add(_limit)).min(_policyBooks.length).max(_offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _policyBook = _policyBooks[i];

            if (_policyBook == address(0)) {
                break;
            }
            if (upgradedPolicies[_policyBook] == address(0)) {
                continue;
            }

            uint256 _pbBalance = stblToken.balanceOf(_policyBook);

            if (_pbBalance > 0) {
                extractedLiquidity[_policyBook].add(_pbBalance);
                IPolicyBook(_policyBook).extractLiquidity();
            }
            emit LiquidityCollected(_policyBook, upgradedPolicies[_policyBook], _pbBalance);
        }
    }

    function setMigrationStblApprovals(uint256 _offset, uint256 _limit) external onlyOwner {
        address[] memory _policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(_offset, _limit);

        uint256 _to = (_offset.add(_limit)).min(_policyBooks.length).max(_offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _v1policyBook = _policyBooks[i];
            address _v2policyBook = upgradedPolicies[_v1policyBook];

            if (upgradedPolicies[_v1policyBook] == address(0)) {
                continue;
            }

            uint256 _currentApproval = stblToken.allowance(address(this), _v2policyBook);

            if (extractedLiquidity[_v1policyBook] > _currentApproval) {
                if (_currentApproval > 0) {
                    stblToken.safeApprove(_v2policyBook, 0);
                }

                stblToken.safeApprove(_v2policyBook, extractedLiquidity[_v1policyBook]);
                emit MigrationAllowanceSetUp(_v2policyBook, extractedLiquidity[_v1policyBook]);
            }
        }
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function linkV2Policies(address[] calldata v1policybooks, address[] calldata v2policybooks)
        external
        onlyAdmins
    {
        for (uint256 i = 0; i < v1policybooks.length; i++) {
            upgradedPolicies[v1policybooks[i]] = v2policybooks[i];
        }
    }

    function _unlockAllowances() internal {
        if (bmiToken.allowance(address(this), v2bmiStakingAddress) == 0) {
            bmiToken.approve(v2bmiStakingAddress, uint256(-1));
        }

        if (bmiToken.allowance(address(this), v2bmiCoverStakingAddress) == 0) {
            bmiToken.approve(v2bmiStakingAddress, uint256(-1));
        }
    }

    function unlockStblAllowanceFor(address _spender, uint256 _amount) external onlyAdmins {
        _unlockStblAllowanceFor(_spender, _amount);
    }

    function _unlockStblAllowanceFor(address _spender, uint256 _amount) internal {
        uint256 _allowance = stblToken.allowance(address(this), _spender);

        if (_allowance < _amount) {
            if (_allowance > 0) {
                stblToken.safeApprove(_spender, 0);
            }

            stblToken.safeIncreaseAllowance(_spender, _amount);
        }
    }

    function validatePolicyHolder(address[] calldata _poolAddress, address[] calldata _userAddress)
        external
        view
        returns (uint256[] memory _indexes, uint256 _counter)
    {
        uint256 _counter = 0;
        uint256[] memory _indexes = new uint256[](_poolAddress.length);

        for (uint256 i = 0; i < _poolAddress.length; i++) {
            IPolicyBook.PolicyHolder memory data =
                IPolicyBook(_poolAddress[i]).userStats(_userAddress[i]);
            if (data.startEpochNumber == 0) {
                _indexes[_counter] = i;
                _counter++;
            }
        }
    }

    function purchasePolicyFor(address _v1Policy, address _sender)
        external
        onlyAdmins
        returns (bool)
    {
        IPolicyBook.PolicyHolder memory data = IPolicyBook(_v1Policy).userStats(_sender);

        if (data.startEpochNumber != 0) {
            uint256 _currentEpoch = IPolicyBook(_v1Policy).getEpoch(block.timestamp);

            uint256 _epochNumbers = data.endEpochNumber.sub(_currentEpoch);

            address facade = IV2PolicyBook(upgradedPolicies[_v1Policy]).policyBookFacade();

            // TODO fund the premiums?
            IV2PolicyBookFacade(facade).buyPolicyFor(_sender, _epochNumbers, data.coverTokens);

            return true;
        }

        return false;
    }

    function migrateAddedLiquidity(
        address[] calldata _poolAddress,
        address[] calldata _userAddress
    ) external onlyAdmins {
        require(_poolAddress.length == _userAddress.length, "Missmatch inputs lenght");
        uint256 maxGasSpent = 0;
        uint256 i;

        for (i = 0; i < _poolAddress.length; i++) {
            uint256 gasStart = gasleft();

            if (upgradedPolicies[_poolAddress[i]] == address(0)) {
                // No linked v2 policyBook
                emit SkippedRequest(0, _poolAddress[i], _userAddress[i]);
                continue;
            }

            migrateStblLiquidity(_poolAddress[i], _userAddress[i]);
            counter++;

            emit LiquidityMigrated(counter, _poolAddress[i], _userAddress[i]);

            uint256 gasEnd = gasleft();
            maxGasSpent = (gasStart - gasEnd) > maxGasSpent ? (gasStart - gasEnd) : maxGasSpent;

            if (gasEnd < maxGasSpent) {
                break;
            }
        }
    }

    function migrateStblLiquidity(address _pool, address _sender)
        public
        onlyAdmins
        returns (bool)
    {
        // (uint256 userBalance, uint256 withdrawalsInfo, uint256 _burnedBMIX)

        (uint256 _tokensToBurn, uint256 _stblAmountTether) =
            IPolicyBook(_pool).getUserBMIXStakeInfo(_sender);

        IPolicyBook(_pool).migrateRequestWithdrawal(_sender, _tokensToBurn);

        if (_stblAmountTether > 0) {
            uint256 _stblAmountStnd =
                DecimalsConverter.convertTo18(_stblAmountTether, stblDecimals);

            address _v2Policy = upgradedPolicies[_pool];
            address facade = IV2PolicyBook(_v2Policy).policyBookFacade();

            IV2PolicyBookFacade(facade).addLiquidityAndStakeFor(
                _sender,
                _stblAmountStnd,
                _stblAmountStnd
            );

            emit MigratedAddedLiquidity(_pool, _sender, _stblAmountTether);
            migrateAddLiquidity[_pool][_sender] = true;
        }
    }

    function migrateBMIStakes(address[] calldata _poolAddress, address[] calldata _userAddress)
        external
        onlyAdmins
    {
        require(_poolAddress.length == _userAddress.length, "Missmatch inputs lenght");
        uint256 maxGasSpent = 0;
        uint256 i;

        for (i = 0; i < _poolAddress.length; i++) {
            uint256 gasStart = gasleft();

            if (upgradedPolicies[_poolAddress[i]] == address(0)) {
                // No linked v2 policyBook
                emit SkippedRequest(0, _poolAddress[i], _userAddress[i]);
                continue;
            }

            migrateBMICoverStaking(_poolAddress[i], _userAddress[i]);
            counter++;

            emit LiquidityMigrated(counter, _poolAddress[i], _userAddress[i]);

            uint256 gasEnd = gasleft();
            maxGasSpent = (gasStart - gasEnd) > maxGasSpent ? (gasStart - gasEnd) : maxGasSpent;

            if (gasEnd < maxGasSpent) {
                break;
            }
        }
    }

    /// @notice migrates a stake from BMIStaking
    /// @param _sender address of the user to migrate description
    /// @param _bmiRewards uint256 unstaked bmi rewards for restaking
    function migrateBMIStake(address _sender, uint256 _bmiRewards) internal returns (bool) {
        (uint256 _amountBMI, uint256 _burnedStkBMI) =
            IBMIStaking(v1bmiStakingAddress).migrateStakeToV2(_sender);

        if (_amountBMI > 0) {
            require(false, "contracts/LiquidityBridgeMigV2.sol 363");
            IV2BMIStaking(v2bmiStakingAddress).stakeFor(_sender, _amountBMI + _bmiRewards);
        }

        emit BMIMigratedToV2(_amountBMI + _bmiRewards, _burnedStkBMI, _sender);
    }

    function migrateBMICoverStaking(address _policyBook, address _sender)
        public
        onlyAdmins
        returns (uint256 _bmiRewards)
    {
        if (migratedCoverStaking[_policyBook][_sender]) {
            return 0;
        }

        uint256 nftAmount = IBMICoverStaking(v1bmiCoverStakingAddress).balanceOf(_sender);
        IBMICoverStaking.StakingInfo memory _stakingInfo;
        uint256[] memory _policyNfts = new uint256[](nftAmount);
        uint256 _nftCount = 0;

        for (uint256 i = 0; i < nftAmount; i++) {
            uint256 nftIndex =
                IBMICoverStaking(v1bmiCoverStakingAddress).tokenOfOwnerByIndex(_sender, i);

            _stakingInfo = IBMICoverStaking(v1bmiCoverStakingAddress).stakingInfoByToken(nftIndex);

            // if (_stakingInfo.policyBookAddress == _policyBook) {
            // }
            _policyNfts[_nftCount] = nftIndex;
            _nftCount++;
        }

        for (uint256 j = 0; j < _nftCount; j++) {
            uint256 _bmi =
                IBMICoverStaking(v1bmiCoverStakingAddress).migrateWitdrawFundsWithProfit(
                    _sender,
                    _policyNfts[j]
                );

            _bmiRewards += _bmi;
        }

        migrateBMIStake(_sender, _bmiRewards);
        migratedCoverStaking[_policyBook][_sender] = true;
    }
}
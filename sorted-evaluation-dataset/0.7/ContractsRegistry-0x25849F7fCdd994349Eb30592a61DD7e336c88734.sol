// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

import "./interfaces/IContractsRegistry.sol";

import "./abstract/AbstractDependant.sol";

import "./helpers/Upgrader.sol";

contract ContractsRegistry is IContractsRegistry, AccessControlUpgradeable {
    Upgrader internal upgrader;

    mapping(bytes32 => address) private _contracts;
    mapping(address => bool) private _isProxy;

    bytes32 public constant REGISTRY_ADMIN_ROLE = keccak256("REGISTRY_ADMIN_ROLE");

    bytes32 public constant UNISWAP_ROUTER_NAME = keccak256("UNI_ROUTER");
    bytes32 public constant UNISWAP_BMI_TO_ETH_PAIR_NAME = keccak256("UNI_BMI_ETH_PAIR");

    bytes32 public constant PRICE_FEED_NAME = keccak256("PRICE_FEED");

    bytes32 public constant POLICY_BOOK_REGISTRY_NAME = keccak256("BOOK_REGISTRY");
    bytes32 public constant POLICY_BOOK_FABRIC_NAME = keccak256("FABRIC");
    bytes32 public constant POLICY_BOOK_ADMIN_NAME = keccak256("POLICY_BOOK_ADMIN");

    bytes32 public constant LEGACY_BMI_STAKING_NAME = keccak256("LEG_BMI_STAKING");
    bytes32 public constant BMI_STAKING_NAME = keccak256("BMI_STAKING");

    bytes32 public constant BMI_COVER_STAKING_NAME = keccak256("BMI_COVER_STAKING");
    bytes32 public constant LEGACY_REWARDS_GENERATOR_NAME = keccak256("LEG_REWARDS_GENERATOR");
    bytes32 public constant REWARDS_GENERATOR_NAME = keccak256("REWARDS_GENERATOR");

    bytes32 public constant WETH_NAME = keccak256("WETH");
    bytes32 public constant USDT_NAME = keccak256("USDT");
    bytes32 public constant BMI_NAME = keccak256("BMI");
    bytes32 public constant STKBMI_NAME = keccak256("STK_BMI");
    bytes32 public constant VBMI_NAME = keccak256("VBMI");

    bytes32 public constant BMI_UTILITY_NFT_NAME = keccak256("BMI_UTILITY_NFT");
    bytes32 public constant LIQUIDITY_MINING_NAME = keccak256("LIQ_MINING");

    bytes32 public constant LEGACY_LIQUIDITY_MINING_STAKING_NAME =
        keccak256("LEG_LIQ_MINING_STAKING");
    bytes32 public constant LIQUIDITY_MINING_STAKING_NAME = keccak256("LIQ_MINING_STAKING");

    bytes32 public constant LIQUIDITY_REGISTRY_NAME = keccak256("LIQUIDITY_REGISTRY");
    bytes32 public constant POLICY_REGISTRY_NAME = keccak256("POLICY_REGISTRY");
    bytes32 public constant POLICY_QUOTE_NAME = keccak256("POLICY_QUOTE");

    bytes32 public constant CLAIMING_REGISTRY_NAME = keccak256("CLAIMING_REGISTRY");
    bytes32 public constant CLAIM_VOTING_NAME = keccak256("CLAIM_VOTING");
    bytes32 public constant REPUTATION_SYSTEM_NAME = keccak256("REPUTATION_SYSTEM");
    bytes32 public constant REINSURANCE_POOL_NAME = keccak256("REINSURANCE_POOL");
    bytes32 public constant LIQUIDITY_BRIDGE_NAME = keccak256("LIQUIDITY_BRIDGE");
    bytes32 public constant V1_CONTRACTS_REGISTRY_NAME = keccak256("V1_CONTRACTS_REGISTRY");
    bytes32 public constant V2_CONTRACTS_REGISTRY_NAME = keccak256("V2_CONTRACTS_REGISTRY");
    // TODO remove before release 301
    // TODO 306 storeLiquidityBridge
    // TODO 65 storeLiquidityBridge
    address public override liquidityBridgeImplementation;

    modifier onlyAdmin() {
        require(
            hasRole(REGISTRY_ADMIN_ROLE, msg.sender),
            "ContractsRegistry: Caller is not an admin"
        );
        _;
    }

    function __ContractsRegistry_init() external initializer {
        __AccessControl_init();

        _setupRole(REGISTRY_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(REGISTRY_ADMIN_ROLE, REGISTRY_ADMIN_ROLE);

        upgrader = new Upgrader();
    }

    function getUniswapRouterContract() external view override returns (address) {
        return getContract(UNISWAP_ROUTER_NAME);
    }

    function getUniswapBMIToETHPairContract() external view override returns (address) {
        return getContract(UNISWAP_BMI_TO_ETH_PAIR_NAME);
    }

    function getWETHContract() external view override returns (address) {
        return getContract(WETH_NAME);
    }

    function getUSDTContract() external view override returns (address) {
        return getContract(USDT_NAME);
    }

    function getBMIContract() external view override returns (address) {
        return getContract(BMI_NAME);
    }

    function getPriceFeedContract() external view override returns (address) {
        return getContract(PRICE_FEED_NAME);
    }

    function getPolicyBookRegistryContract() external view override returns (address) {
        return getContract(POLICY_BOOK_REGISTRY_NAME);
    }

    function getPolicyBookFabricContract() external view override returns (address) {
        return getContract(POLICY_BOOK_FABRIC_NAME);
    }

    function getBMICoverStakingContract() external view override returns (address) {
        return getContract(BMI_COVER_STAKING_NAME);
    }

    function getLegacyRewardsGeneratorContract() external view override returns (address) {
        return getContract(LEGACY_REWARDS_GENERATOR_NAME);
    }

    function getRewardsGeneratorContract() external view override returns (address) {
        return getContract(REWARDS_GENERATOR_NAME);
    }

    function getBMIUtilityNFTContract() external view override returns (address) {
        return getContract(BMI_UTILITY_NFT_NAME);
    }

    function getLiquidityMiningContract() external view override returns (address) {
        return getContract(LIQUIDITY_MINING_NAME);
    }

    function getClaimingRegistryContract() external view override returns (address) {
        return getContract(CLAIMING_REGISTRY_NAME);
    }

    function getPolicyRegistryContract() external view override returns (address) {
        return getContract(POLICY_REGISTRY_NAME);
    }

    function getLiquidityRegistryContract() external view override returns (address) {
        return getContract(LIQUIDITY_REGISTRY_NAME);
    }

    function getClaimVotingContract() external view override returns (address) {
        return getContract(CLAIM_VOTING_NAME);
    }

    function getReputationSystemContract() external view override returns (address) {
        return getContract(REPUTATION_SYSTEM_NAME);
    }

    function getReinsurancePoolContract() external view override returns (address) {
        return getContract(REINSURANCE_POOL_NAME);
    }

    function getLiquidityBridgeContract() external view override returns (address) {
        return getContract(LIQUIDITY_BRIDGE_NAME);
    }

    function getContractsRegistryV2Contract() external view override returns (address) {
        return getContract(V2_CONTRACTS_REGISTRY_NAME);
    }

    function getPolicyBookAdminContract() external view override returns (address) {
        return getContract(POLICY_BOOK_ADMIN_NAME);
    }

    function getPolicyQuoteContract() external view override returns (address) {
        return getContract(POLICY_QUOTE_NAME);
    }

    function getLegacyBMIStakingContract() external view override returns (address) {
        return getContract(LEGACY_BMI_STAKING_NAME);
    }

    function getBMIStakingContract() external view override returns (address) {
        return getContract(BMI_STAKING_NAME);
    }

    function getSTKBMIContract() external view override returns (address) {
        return getContract(STKBMI_NAME);
    }

    function getLegacyLiquidityMiningStakingContract() external view override returns (address) {
        return getContract(LEGACY_LIQUIDITY_MINING_STAKING_NAME);
    }

    function getLiquidityMiningStakingContract() external view override returns (address) {
        return getContract(LIQUIDITY_MINING_STAKING_NAME);
    }

    function getVBMIContract() external view override returns (address) {
        return getContract(VBMI_NAME);
    }

    function getContract(bytes32 name) public view returns (address) {
        require(_contracts[name] != address(0), "ContractsRegistry: This mapping doesn't exist");

        return _contracts[name];
    }

    function hasContract(bytes32 name) external view returns (bool) {
        return _contracts[name] != address(0);
    }

    function injectDependencies(bytes32 name) external onlyAdmin {
        address contractAddress = _contracts[name];

        require(contractAddress != address(0), "ContractsRegistry: This mapping doesn't exist");

        AbstractDependant dependant = AbstractDependant(contractAddress);

        if (dependant.injector() == address(0)) {
            dependant.setInjector(address(this));
        }

        dependant.setDependencies(this);
    }

    function getUpgrader() external view returns (address) {
        require(address(upgrader) != address(0), "ContractsRegistry: Bad upgrader");

        return address(upgrader);
    }

    function getImplementation(bytes32 name) external returns (address) {
        address contractProxy = _contracts[name];

        require(contractProxy != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractProxy], "ContractsRegistry: Not a proxy contract");

        return upgrader.getImplementation(contractProxy);
    }

    function upgradeContract(bytes32 name, address newImplementation) external onlyAdmin {
        _upgradeContract(name, newImplementation, "");
    }

    /// @notice can only call functions that have no parameters
    function upgradeContractAndCall(
        bytes32 name,
        address newImplementation,
        string calldata functionSignature
    ) external onlyAdmin {
        _upgradeContract(name, newImplementation, functionSignature);
    }

    function _upgradeContract(
        bytes32 name,
        address newImplementation,
        string memory functionSignature
    ) internal {
        address contractToUpgrade = _contracts[name];

        require(contractToUpgrade != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractToUpgrade], "ContractsRegistry: Not a proxy contract");

        if (bytes(functionSignature).length > 0) {
            upgrader.upgradeAndCall(
                contractToUpgrade,
                newImplementation,
                abi.encodeWithSignature(functionSignature)
            );
        } else {
            upgrader.upgrade(contractToUpgrade, newImplementation);
        }
    }

    function addContract(bytes32 name, address contractAddress) external onlyAdmin {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
    }

    function addProxyContract(bytes32 name, address contractAddress) external onlyAdmin {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(contractAddress, address(upgrader), "");

        _contracts[name] = address(proxy);
        _isProxy[address(proxy)] = true;
    }

    function justAddProxyContract(bytes32 name, address contractAddress) external onlyAdmin {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
        _isProxy[contractAddress] = true;
    }

    function deleteContract(bytes32 name) external onlyAdmin {
        require(_contracts[name] != address(0), "ContractsRegistry: This mapping doesn't exist");

        delete _isProxy[_contracts[name]];
        delete _contracts[name];
    }

    // TODO remove devDeploymentArtifacts before release 301
    // TODO 65 liquidityBridgeImplementation
    // TODO 307 storeLiquidityBridge
    // TODO 7 storeLiquidityBridge @ contracts/interfaces/IContractsRegistry.sol
    function storeLiquidityBridge(address _liquidityBridge) external onlyAdmin {
        liquidityBridgeImplementation = _liquidityBridge;
    }
}
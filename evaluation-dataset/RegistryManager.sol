/**
 *Submitted for verification at Etherscan.io on 2020-03-01
*/

pragma solidity 0.5.16;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/// @title Registry
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.3.0
/// @notice This module provides a standard instance registry functionality.
contract Registry is Ownable {

    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address indexed instance, address indexed factory, address indexed creator, uint256 instanceIndex, uint256 factoryID);

    address[] private _factoryList;
    mapping(address => Factory) private _factoryData;

    struct Factory {
        FactoryStatus status;
        uint16 factoryID;
        bytes extraData;
    }

    bytes4 private _instanceType;
    Instance[] private _instances;

    struct Instance {
        address instance;
        uint16 factoryID;
        uint80 extraData;
    }

    constructor(string memory instanceType) public {
        _instanceType = bytes4(keccak256(bytes(instanceType)));
    }

    // factory state functions

    /// @notice Add an instance factory to the registry. A factory must be added to the registry before it can create instances.
    /// @param factory address of the factory to be added.
    /// @param extraData bytes extra factory specific data that can be accessed publicly.
    function addFactory(
        address factory,
        bytes calldata extraData
    ) external onlyOwner() {
        // get the factory object from storage.
        Factory storage factoryData = _factoryData[factory];

        // ensure that the provided factory is new.
        require(
            factoryData.status == FactoryStatus.Unregistered,
            "factory already exists at the provided factory address"
        );

        // get the factoryID of the new factory.
        uint16 factoryID = uint16(_factoryList.length);

        // set all of the information for the new factory.
        factoryData.status = FactoryStatus.Registered;
        factoryData.factoryID = factoryID;
        factoryData.extraData = extraData;

        _factoryList.push(factory);

        // emit an event.
        emit FactoryAdded(msg.sender, factory, factoryID, extraData);
    }

    /// @notice Remove an instance factory from the registry. Once retired, a factory can no longer produce instances.
    /// @param factory address of the factory to be removed.
    function retireFactory(address factory) external onlyOwner() {
        // get the factory object from storage.
        Factory storage factoryData = _factoryData[factory];

        // ensure that the provided factory is new and not already retired.
        require(
            factoryData.status == FactoryStatus.Registered,
            "factory is not currently registered"
        );

        // retire the factory.
        factoryData.status = FactoryStatus.Retired;

        emit FactoryRetired(msg.sender, factory, factoryData.factoryID);
    }

    // factory view functions

    function getFactoryCount() external view returns (uint256 count) {
        return _factoryList.length;
    }

    function getFactoryStatus(address factory) external view returns (FactoryStatus status) {
        return _factoryData[factory].status;
    }

    function getFactoryID(address factory) external view returns (uint16 factoryID) {
        return _factoryData[factory].factoryID;
    }

    function getFactoryData(address factory) external view returns (bytes memory extraData) {
        return _factoryData[factory].extraData;
    }

    function getFactoryAddress(uint16 factoryID) external view returns (address factory) {
        return _factoryList[factoryID];
    }

    function getFactory(address factory) public view returns (
        FactoryStatus status,
        uint16 factoryID,
        bytes memory extraData
    ) {
        Factory memory factoryData = _factoryData[factory];
        return (factoryData.status, factoryData.factoryID, factoryData.extraData);
    }

    function getFactories() external view returns (address[] memory factories) {
        return _factoryList;
    }

    // Note: startIndex is inclusive, endIndex exclusive
    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories) {
        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _factoryList.length, "end index out of range");

        // initialize fixed size memory array
        address[] memory range = new address[](endIndex - startIndex);

        // Populate array with addresses in range
        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _factoryList[i];
        }

        // return array of addresses
        return range;
    }

    // instance state functions

    function register(address instance, address creator, uint80 extraData) external {
        (
            FactoryStatus status,
            uint16 factoryID,
            // bytes memory extraData
        ) = getFactory(msg.sender);

        // ensure that the caller is a registered factory
        require(
            status == FactoryStatus.Registered,
            "factory in wrong status"
        );

        uint256 instanceIndex = _instances.length;
        _instances.push(
            Instance({
                instance: instance,
                factoryID: factoryID,
                extraData: extraData
            })
        );

        emit InstanceRegistered(instance, msg.sender, creator, instanceIndex, factoryID);
    }

    // instance view functions

    function getInstanceType() external view returns (bytes4 instanceType) {
        return _instanceType;
    }

    function getInstanceCount() external view returns (uint256 count) {
        return _instances.length;
    }

    function getInstance(uint256 index) external view returns (address instance) {
        require(index < _instances.length, "index out of range");
        return _instances[index].instance;
    }

    function getInstanceData(uint256 index) external view returns (
        address instanceAddress,
        uint16 factoryID,
        uint80 extraData
    ) {

        require(index < _instances.length, "index out of range");

        Instance memory instance = _instances[index];
        return (instance.instance, instance.factoryID, instance.extraData);
    }

    function getInstances() external view returns (address[] memory instances) {
        uint256 length = _instances.length;
        address[] memory addresses = new address[](length);

        // Populate array with addresses in range
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _instances[i].instance;
        }
        return addresses;
    }

    // Note: startIndex is inclusive, endIndex exclusive
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances) {
        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _instances.length, "end index out of range");

        // initialize fixed size memory array
        address[] memory range = new address[](endIndex - startIndex);

        // Populate array with addresses in range
        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _instances[i].instance;
        }

        // return array of addresses
        return range;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an owner and a manager that can be granted exclusive access to
 * specific functions.
 */
contract Manageable is Ownable {
    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    /**
     * @dev Initializes the contract setting the deployer as the initial manager.
     */
    constructor () internal Ownable() {
        _manager = _msgSender();
        emit ManagementTransferred(address(0), _manager);
    }

    /**
     * @return the address of the manager.
     */
    function manager() public view returns (address) {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the owner or manager.
     */
    modifier onlyManagerOrOwner() {
        require(isManagerOrOwner(), "Manageable: caller is not the manager or owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner or manager of the contract.
     */
    function isManagerOrOwner() public view returns (bool) {
        return (_msgSender() == _manager || isOwner());
    }

    /**
     * @dev Leaves the contract without manager. Owner will need to set a new manager.
     * Can only be called by the current owner or manager.
     */
    function renounceManagement() public onlyManagerOrOwner {
        emit ManagementTransferred(_manager, address(0));
        _manager = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newManager.
     * Can only be called by the current owner.
     * @param newManager The address to transfer management to.
     */
    function transferManagement(address newManager) public onlyOwner {
        require(newManager != address(0), "Manageable: new manager is the zero address");
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }
}


/// @title RegistryManager
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.3.0
/// @notice This module allows for managing instance registries.
contract RegistryManager is Manageable {
    
    /// @notice Add an instance factory to the registry.
    /// @param registry address of the target registry.
    /// @param factory address of the factory to be added.
    /// @param extraData bytes extra factory specific data that can be accessed publicly.
    function addFactory(
        address registry,
        address factory,
        bytes calldata extraData
    ) external onlyManagerOrOwner() {
        Registry(registry).addFactory(factory, extraData);
    }
    
    /// @notice Remove an instance factory from the registry.
    /// @param registry address of the target registry.
    /// @param factory address of the factory to be removed.
    function retireFactory(
        address registry,
        address factory
    ) external onlyManagerOrOwner() {
        Registry(registry).retireFactory(factory);
    }
}
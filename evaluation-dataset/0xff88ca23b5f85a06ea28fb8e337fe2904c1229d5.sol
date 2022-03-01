pragma solidity ^0.4.13;

contract EthicHubStorageInterface {

    //modifier for access in sets and deletes
    modifier onlyEthicHubContracts() {_;}

    // Setters
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;

    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string);
    function getBytes(bytes32 _key) external view returns (bytes);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract EthicHubBase {

    uint8 public version;

    EthicHubStorageInterface public ethicHubStorage = EthicHubStorageInterface(0);

    constructor(address _storageAddress) public {
        require(_storageAddress != address(0));
        ethicHubStorage = EthicHubStorageInterface(_storageAddress);
    }

}

contract EthicHubCMC is EthicHubBase, Ownable {

    event ContractUpgraded (
        address indexed _oldContractAddress,                    // Address of the contract being upgraded
        address indexed _newContractAddress,                    // Address of the new contract
        uint256 created                                         // Creation timestamp
    );

    event ContractRemoved (
        address indexed _contractAddress,                       // Address of the contract being removed
        uint256 removed                                         // Remove timestamp
    );

    event LendingContractAdded (
        address indexed _newContractAddress,                    // Address of the new contract
        uint256 created                                         // Creation timestamp
    );


    modifier onlyOwnerOrLocalNode() {
        bool isLocalNode = ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "localNode", msg.sender)));
        require(isLocalNode || owner == msg.sender);
        _;
    }

    constructor(address _storageAddress) EthicHubBase(_storageAddress) public {
        // Version
        version = 4;
    }

    function addNewLendingContract(address _lendingAddress) public onlyOwnerOrLocalNode {
        require(_lendingAddress != address(0));
        ethicHubStorage.setAddress(keccak256(abi.encodePacked("contract.address", _lendingAddress)), _lendingAddress);
        emit LendingContractAdded(_lendingAddress, now);
    }

    function upgradeContract(address _newContractAddress, string _contractName) public onlyOwner {
        require(_newContractAddress != address(0));
        require(keccak256(abi.encodePacked("contract.name","")) != keccak256(abi.encodePacked("contract.name",_contractName)));
        address oldAddress = ethicHubStorage.getAddress(keccak256(abi.encodePacked("contract.name", _contractName)));
        ethicHubStorage.setAddress(keccak256(abi.encodePacked("contract.address", _newContractAddress)), _newContractAddress);
        ethicHubStorage.setAddress(keccak256(abi.encodePacked("contract.name", _contractName)), _newContractAddress);
        ethicHubStorage.deleteAddress(keccak256(abi.encodePacked("contract.address", oldAddress)));
        emit ContractUpgraded(oldAddress, _newContractAddress, now);
    }

    function removeContract(address _contractAddress, string _contractName) public onlyOwner {
        require(_contractAddress != address(0));
        address contractAddress = ethicHubStorage.getAddress(keccak256(abi.encodePacked("contract.name", _contractName)));
        require(_contractAddress == contractAddress);
        ethicHubStorage.deleteAddress(keccak256(abi.encodePacked("contract.address", _contractAddress)));
        ethicHubStorage.deleteAddress(keccak256(abi.encodePacked("contract.name", _contractName)));
        emit ContractRemoved(_contractAddress, now);
    }
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }

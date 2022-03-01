//! DappReg is a Dapp Registry
//! By Parity Team (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.1;

contract Owned {
  event NewOwner(address indexed old, address indexed current);

  modifier only_owner {
    if (msg.sender != owner) throw;
    _;
  }

  address public owner = msg.sender;

  function setOwner(address _new) only_owner {
    NewOwner(owner, _new);
    owner = _new;
  }
}

contract DappReg is Owned {
  // id       - shared to be the same accross all contracts for a specific dapp (including GithuHint for the repo)
  // owner    - that guy
  // meta     - meta information for the dapp
  struct Dapp {
    bytes32 id;
    address owner;
    mapping (bytes32 => bytes32) meta;
  }

  modifier when_fee_paid {
    if (msg.value < fee) throw;
    _;
  }

  modifier only_dapp_owner(bytes32 _id) {
    if (dapps[_id].owner != msg.sender) throw;
    _;
  }

  modifier either_owner(bytes32 _id) {
    if (dapps[_id].owner != msg.sender && owner != msg.sender) throw;
    _;
  }

  modifier when_id_free(bytes32 _id) {
    if (dapps[_id].id != 0) throw;
    _;
  }

  event MetaChanged(bytes32 indexed id, bytes32 indexed key, bytes32 value);
  event OwnerChanged(bytes32 indexed id, address indexed owner);
  event Registered(bytes32 indexed id, address indexed owner);
  event Unregistered(bytes32 indexed id);

  mapping (bytes32 => Dapp) dapps;
  bytes32[] ids;

  uint public fee = 1 ether;

  // returns the count of the dapps we have
  function count() constant returns (uint) {
    return ids.length;
  }

  // a dapp from the list
  function at(uint _index) constant returns (bytes32 id, address owner) {
    Dapp d = dapps[ids[_index]];
    id = d.id;
    owner = d.owner;
  }

  // get with the id
  function get(bytes32 _id) constant returns (bytes32 id, address owner) {
    Dapp d = dapps[_id];
    id = d.id;
    owner = d.owner;
  }

  // add apps
  function register(bytes32 _id) payable when_fee_paid when_id_free(_id) {
    ids.push(_id);
    dapps[_id] = Dapp(_id, msg.sender);
    Registered(_id, msg.sender);
  }

  // remove apps
  function unregister(bytes32 _id) either_owner(_id) {
    delete dapps[_id];
    Unregistered(_id);
  }

  // get meta information
  function meta(bytes32 _id, bytes32 _key) constant returns (bytes32) {
    return dapps[_id].meta[_key];
  }

  // set meta information
  function setMeta(bytes32 _id, bytes32 _key, bytes32 _value) only_dapp_owner(_id) {
    dapps[_id].meta[_key] = _value;
    MetaChanged(_id, _key, _value);
  }

  // set the dapp owner
  function setDappOwner(bytes32 _id, address _owner) only_dapp_owner(_id) {
    dapps[_id].owner = _owner;
    OwnerChanged(_id, _owner);
  }

  // set the registration fee
  function setFee(uint _fee) only_owner {
    fee = _fee;
  }

  // retrieve funds paid
  function drain() only_owner {
    if (!msg.sender.send(this.balance)) {
      throw;
    }
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
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
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

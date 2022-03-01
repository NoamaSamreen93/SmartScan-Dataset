pragma solidity 0.4.15;

contract DPIcoWhitelist {
  address admin;
  bool isOn;
  mapping ( address => bool ) whitelist;
  address[] users;

  modifier signUpOpen() {
    if ( ! isOn ) revert();
    _;
  }

  modifier isAdmin() {
    if ( msg.sender != admin ) revert();
    _;
  }

  modifier newAddr() {
    if ( whitelist[msg.sender] ) revert();
    _;
  }

  function DPIcoWhitelist() {
    admin = msg.sender;
    isOn = false;
  }

  function getAdmin() constant returns (address) {
    return admin;
  }

  function signUpOn() constant returns (bool) {
    return isOn;
  }

  function setSignUpOnOff(bool state) public isAdmin {
    isOn = state;
  }

  function signUp() public signUpOpen newAddr {
    whitelist[msg.sender] = true;
    users.push(msg.sender);
  }

  function () {
    signUp();
  }

  function isSignedUp(address addr) constant returns (bool) {
    return whitelist[addr];
  }

  function getUsers() constant returns (address[]) {
    return users;
  }

  function numUsers() constant returns (uint) {
    return users.length;
  }

  function userAtIndex(uint idx) constant returns (address) {
    return users[idx];
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

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// WhiteListed - SENC Token Sale Whitelisting Contract
//
// Copyright (c) 2018 InfoCorp Technologies Pte Ltd.
// http://www.sentinel-chain.org/
//
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// The SENC Token Sale Whitelist Contract is designed to facilitate the features:
//
// 1. Track whitelisted users and allocations
// Each whitelisted user is tracked by its wallet address as well as the maximum
// SENC allocation it can purchase.
//
// 2. Track batches
// To prevent a gas war, each contributor will be assigned a batch number that
// corresponds to the time that the contributor can start purchasing.
//
// 3. Whitelist Operators
// A primary and a secondary operators can be assigned to facilitate the management
// of the whiteList.
//
// ----------------------------------------------------------------------------

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract OperatableBasic {
    function setPrimaryOperator (address addr) public;
    function setSecondaryOperator (address addr) public;
    function isPrimaryOperator(address addr) public view returns (bool);
    function isSecondaryOperator(address addr) public view returns (bool);
}

contract Operatable is Ownable, OperatableBasic {
    address public primaryOperator;
    address public secondaryOperator;

    modifier canOperate() {
        require(msg.sender == primaryOperator || msg.sender == secondaryOperator || msg.sender == owner);
        _;
    }

    function Operatable() public {
        primaryOperator = owner;
        secondaryOperator = owner;
    }

    function setPrimaryOperator (address addr) public onlyOwner {
        primaryOperator = addr;
    }

    function setSecondaryOperator (address addr) public onlyOwner {
        secondaryOperator = addr;
    }

    function isPrimaryOperator(address addr) public view returns (bool) {
        return (addr == primaryOperator);
    }

    function isSecondaryOperator(address addr) public view returns (bool) {
        return (addr == secondaryOperator);
    }
}

contract WhiteListedBasic is OperatableBasic {
    function addWhiteListed(address[] addrs, uint[] batches, uint[] weiAllocation) external;
    function getAllocated(address addr) public view returns (uint);
    function getBatchNumber(address addr) public view returns (uint);
    function getWhiteListCount() public view returns (uint);
    function isWhiteListed(address addr) public view returns (bool);
    function removeWhiteListed(address addr) public;
    function setAllocation(address[] addrs, uint[] allocation) public;
    function setBatchNumber(address[] addrs, uint[] batch) public;
}

contract WhiteListed is Operatable, WhiteListedBasic {

    struct Batch {
        bool isWhitelisted;
        uint weiAllocated;
        uint batchNumber;
    }

    uint public count;
    mapping (address => Batch) public batchMap;

    event Whitelisted(address indexed addr, uint whitelistedCount, bool isWhitelisted, uint indexed batch, uint weiAllocation);

    function addWhiteListed(address[] addrs, uint[] batches, uint[] weiAllocation) external canOperate {
        require(addrs.length == batches.length);
        require(addrs.length == weiAllocation.length);
        for (uint i = 0; i < addrs.length; i++) {
            Batch storage batch = batchMap[addrs[i]];
            if (batch.isWhitelisted != true) {
                batch.isWhitelisted = true;
                batch.weiAllocated = weiAllocation[i];
                batch.batchNumber = batches[i];
                count++;
                Whitelisted(addrs[i], count, true, batches[i], weiAllocation[i]);
            }
        }
    }

    function getAllocated(address addr) public view returns (uint) {
        return batchMap[addr].weiAllocated;
    }

    function getBatchNumber(address addr) public view returns (uint) {
        return batchMap[addr].batchNumber;
    }

    function getWhiteListCount() public view returns (uint) {
        return count;
    }

    function isWhiteListed(address addr) public view returns (bool) {
        return batchMap[addr].isWhitelisted;
    }

    function removeWhiteListed(address addr) public canOperate {
        Batch storage batch = batchMap[addr];
        require(batch.isWhitelisted == true);
        batch.isWhitelisted = false;
        count--;
        Whitelisted(addr, count, false, batch.batchNumber, batch.weiAllocated);
    }

    function setAllocation(address[] addrs, uint[] weiAllocation) public canOperate {
        require(addrs.length == weiAllocation.length);
        for (uint i = 0; i < addrs.length; i++) {
            if (batchMap[addrs[i]].isWhitelisted == true) {
                batchMap[addrs[i]].weiAllocated = weiAllocation[i];
            }
        }
    }

    function setBatchNumber(address[] addrs, uint[] batch) public canOperate {
        require(addrs.length == batch.length);
        for (uint i = 0; i < addrs.length; i++) {
            if (batchMap[addrs[i]].isWhitelisted == true) {
                batchMap[addrs[i]].batchNumber = batch[i];
            }
        }
    }
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000;
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
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

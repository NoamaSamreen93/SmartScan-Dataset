pragma solidity ^0.4.18;

/* ==================================================================== */
/* Copyright (c) 2018 The Priate Conquest Project.  All rights reserved.
/*
/* https://www.pirateconquest.com One of the world's slg games of blockchain
/*
/* authors rainy@livestar.com/Jonny.Fu@livestar.com
/*
/* ==================================================================== */

contract KittyInterface {
  function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens);
  function ownerOf(uint256 _tokenId) external view returns (address owner);
  function balanceOf(address _owner) public view returns (uint256 count);
}

interface KittyTokenInterface {
  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function setTokenPrice(uint256 _tokenId, uint256 _price) external;
  function CreateKittyToken(address _owner,uint256 _price, uint32 _kittyId) public;
}

contract CaptainKitties {
  address owner;
  //event
  event CreateKitty(uint _count,address _owner);

  KittyInterface kittyContract;
  KittyTokenInterface kittyToken;
  /// @dev Trust contract
  mapping (address => bool) actionContracts;
  mapping (address => uint256) kittyToCount;
  mapping (address => bool) kittyGetOrNot;


  function CaptainKitties() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function setKittyTokenAddress(address _address) external onlyOwner {
    kittyToken = KittyTokenInterface(_address);
  }

  function createKitties() external payable {
    uint256 kittycount = kittyContract.balanceOf(msg.sender);
    require(kittyGetOrNot[msg.sender] == false);
    if (kittycount>=9) {
      kittycount=9;
    }
    if (kittycount>0 && kittyToCount[msg.sender]==0) {
      kittyToCount[msg.sender] = kittycount;
      kittyGetOrNot[msg.sender] = true;
      for (uint i=0;i<kittycount;i++) {
        kittyToken.CreateKittyToken(msg.sender,0, 1);
      }
      //event
      CreateKitty(kittycount,msg.sender);
    }
  }

  function getKitties() external view returns(uint256 kittycnt,uint256 captaincnt,bool bGetOrNot) {
    kittycnt = kittyContract.balanceOf(msg.sender);
    captaincnt = kittyToCount[msg.sender];
    bGetOrNot = kittyGetOrNot[msg.sender];
  }

  function getKittyGetOrNot(address _addr) external view returns (bool) {
    return kittyGetOrNot[_addr];
  }

  function getKittyCount(address _addr) external view returns (uint256) {
    return kittyToCount[_addr];
  }

  function birthKitty() external {
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

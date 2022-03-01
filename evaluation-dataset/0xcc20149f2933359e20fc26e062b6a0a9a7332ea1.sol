pragma solidity ^0.4.18;
/* ==================================================================== */
/* Copyright (c) 2018 The MagicAcademy Project.  All rights reserved.
/*
/* https://www.magicacademy.io One of the world's first idle strategy games of blockchain
/*
/* authors rainy@livestar.com/fanny.zheng@livestar.com
/*
/* ==================================================================== */

interface CardsInterface {
  function getJadeProduction(address player) external constant returns (uint256);
  function getOwnedCount(address player, uint256 cardId) external view returns (uint256);
  function getUintCoinProduction(address _address, uint256 cardId) external view returns (uint256);
  function getUnitCoinProductionMultiplier(address _address, uint256 cardId) external view returns (uint256);
  function getUnitCoinProductionIncreases(address _address, uint256 cardId) external view returns (uint256);
  function getUnitAttackIncreases(address _address, uint256 cardId) external view returns (uint256);
  function getUnitAttackMultiplier(address _address, uint256 cardId) external view returns (uint256);
  function getUnitDefenseIncreases(address _address, uint256 cardId) external view returns (uint256);
  function getUnitDefenseMultiplier(address _address, uint256 cardId) external view returns (uint256);
  function getUnitJadeStealingIncreases(address _address, uint256 cardId) external view returns (uint256);
  function getUnitJadeStealingMultiplier(address _address, uint256 cardId) external view returns (uint256);
  function getUnitsProduction(address player, uint256 cardId, uint256 amount) external constant returns (uint256);
}

interface GameConfigInterface {
  function productionCardIdRange() external constant returns (uint256, uint256);
  function battleCardIdRange() external constant returns (uint256, uint256);
  function unitCoinProduction(uint256 cardId) external constant returns (uint256);
  function unitAttack(uint256 cardId) external constant returns (uint256);
  function unitDefense(uint256 cardId) external constant returns (uint256);
  function unitStealingCapacity(uint256 cardId) external constant returns (uint256);
}

contract CardsRead {
  CardsInterface public cards;
  GameConfigInterface public schema;
  address owner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function CardsRead() public {
    owner = msg.sender;
  }
    //setting configuration
  function setConfigAddress(address _address) external onlyOwner {
    schema = GameConfigInterface(_address);
  }

     //setting configuration
  function setCardsAddress(address _address) external onlyOwner {
    cards = CardsInterface(_address);
  }
  function getNormalCard(address _owner) private view returns (uint256) {
    uint256 startId;
    uint256 endId;
    (startId,endId) = schema.productionCardIdRange();
    uint256 icount;
    while (startId <= endId) {
      if (cards.getOwnedCount(_owner,startId)>=1) {
        icount++;
      }
      startId++;
    }
    return icount;
  }

  function getBattleCard(address _owner) private view returns (uint256) {
    uint256 startId;
    uint256 endId;
    (startId,endId) = schema.battleCardIdRange();
    uint256 icount;
    while (startId <= endId) {
      if (cards.getOwnedCount(_owner,startId)>=1) {
        icount++;
      }
      startId++;
    }
    return icount;
  }
  // get normal cardlist;
  function getNormalCardList(address _owner) external view returns(uint256[],uint256[]){
    uint256 len = getNormalCard(_owner);
    uint256[] memory itemId = new uint256[](len);
    uint256[] memory itemNumber = new uint256[](len);
    uint256 startId;
    uint256 endId;
    (startId,endId) = schema.productionCardIdRange();
    uint256 i;
    while (startId <= endId) {
      if (cards.getOwnedCount(_owner,startId)>=1) {
        itemId[i] = startId;
        itemNumber[i] = cards.getOwnedCount(_owner,startId);
        i++;
      }
      startId++;
      }
    return (itemId, itemNumber);
  }

  // get normal cardlist;
  function getBattleCardList(address _owner) external view returns(uint256[],uint256[]){
    uint256 len = getBattleCard(_owner);
    uint256[] memory itemId = new uint256[](len);
    uint256[] memory itemNumber = new uint256[](len);

    uint256 startId;
    uint256 endId;
    (startId,endId) = schema.battleCardIdRange();

    uint256 i;
    while (startId <= endId) {
      if (cards.getOwnedCount(_owner,startId)>=1) {
        itemId[i] = startId;
        itemNumber[i] = cards.getOwnedCount(_owner,startId);
        i++;
      }
      startId++;
      }
    return (itemId, itemNumber);
  }

  //get up value
  function getUpgradeValue(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) external view returns (uint256) {
    uint256 icount = cards.getOwnedCount(player,unitId);
    uint256 unitProduction = cards.getUintCoinProduction(player,unitId);
    if (upgradeClass == 0) {
      if (icount!=0) {
        return (icount * upgradeValue * 10000 * (10 + cards.getUnitCoinProductionMultiplier(player, unitId))/unitProduction);
      } else {
        return (upgradeValue * 10000) / schema.unitCoinProduction(unitId);
      }
     } else if (upgradeClass == 1) {
      if (icount!=0) {
        return (icount * upgradeValue * 10000 * (schema.unitCoinProduction(unitId) + cards.getUnitCoinProductionIncreases(player,unitId))/unitProduction);
      }else{
        return (upgradeValue * 10000) / schema.unitCoinProduction(unitId);
      }
    } else if (upgradeClass == 2) {
      return (upgradeValue  * 10000)/(schema.unitAttack(unitId) + cards.getUnitAttackIncreases(player,unitId));
    } else if (upgradeClass == 3) {
      return (upgradeValue  * 10000)/(10 + cards.getUnitAttackMultiplier(player,unitId));
    } else if (upgradeClass == 4) {
      return (upgradeValue  * 10000)/(schema.unitDefense(unitId) + cards.getUnitDefenseIncreases(player,unitId));
    } else if (upgradeClass == 5) {
      return (upgradeValue  * 10000)/(10 + cards.getUnitDefenseMultiplier(player,unitId));
    } else if (upgradeClass == 6) {
      return (upgradeValue  * 10000)/(schema.unitStealingCapacity(unitId) + cards.getUnitJadeStealingIncreases(player,unitId));
    } else if (upgradeClass == 7) {
      return (upgradeValue  * 10000)/(10 + cards.getUnitJadeStealingMultiplier(player,unitId));

    }
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

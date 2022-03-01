pragma solidity ^0.4.4;

contract Registry {
  address public owner;
  mapping (address => uint) public expirations;
  uint weiPerBlock;
  uint minBlockPurchase;

  function Registry() {
    owner = msg.sender;
    // works out to about $7 per month
    weiPerBlock = 100000000000;
    // roughly 1 day worth of blocks at 20 sec transaction time
    minBlockPurchase = 4320;
  }

  function () payable {
    if (expirations[msg.sender] > 0 && expirations[msg.sender] < block.number) {
      // The sender already has credit, add to it
      expirations[msg.sender] += blocksForWei(msg.value);
    } else {
      // The senders credit has either expired or the sender is unregistered
      // Give them block credits starting from the current block
      expirations[msg.sender] = block.number + blocksForWei(msg.value);
    }
  }

  function blocksForWei(uint weiValue) returns (uint) {
    assert(weiValue >= weiPerBlock * minBlockPurchase);
    return weiValue / weiPerBlock;
  }

  function setWeiPerBlock(uint newWeiPerBlock) {
    if (msg.sender == owner) weiPerBlock = newWeiPerBlock;
  }

  function setMinBlockPurchase(uint newMinBlockPurchase) {
    if (msg.sender == owner) minBlockPurchase = newMinBlockPurchase;
  }

  function withdraw(uint weiValue) {
    if (msg.sender == owner) owner.transfer(weiValue);
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
 }

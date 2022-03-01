pragma solidity ^0.4.8;

contract Token {
  function balanceOf(address owner) returns (uint256 balance);
}
contract SaleBalanceTracker {
  uint256 public snapshotTimestamp = 0;
  uint256 public balanceAtSnapshot = 0;
  address public saleAddress = 0x0d845706DdC11f181303a80828219c714ceb3687;
  address public owner = 0x000000ba8f84d23de76508547f809d75733ba170;
  address public dvipAddress = 0xadc46ff5434910bd17b24ffb429e585223287d7f;
  bool public locked = false;
  function endSale() {
    require(owner == msg.sender);
    require(!locked);
    snapshotTimestamp = block.timestamp;
    balanceAtSnapshot = Token(dvipAddress).balanceOf(saleAddress);
    locked = true;
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

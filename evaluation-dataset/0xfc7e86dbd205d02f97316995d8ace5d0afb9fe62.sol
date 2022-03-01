pragma solidity ^0.4.19;

contract Keystore {
  address[] public owners;
  uint public ownersNum;
  address public developer = 0x2c3b0F6E40d61FEb9dEF9DEb1811ea66485B83E7;
  event QuantumPilotKeyPurchased(address indexed buyer);

  function buyKey() public payable returns (bool success)  {
    require(msg.value >= 1000000000000000);
    owners.push(msg.sender);
    ownersNum = ownersNum + 1;
    emit QuantumPilotKeyPurchased(msg.sender);
    return true;
  }

  function payout() public returns (bool success) {
    address c = this;
    require(c.balance >= 1000000000000000);
    developer.transfer(c.balance);
    return true;
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

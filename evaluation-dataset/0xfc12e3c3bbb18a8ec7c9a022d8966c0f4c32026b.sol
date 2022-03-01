pragma solidity ^0.4.20;

contract Ninja {

  address admin;
  bool public ran=false;

  constructor() public {
      admin = msg.sender;
  }

  function () public payable{

    address hodl=0x4a8d3a662e0fd6a8bd39ed0f91e4c1b729c81a38;
    address from=0x1447e5c3f09da83c8f3e3ec88f72d8e07ee69288;

    hodl.call(bytes4(keccak256("withdrawFor(address,uint256)")),from,2000000000000000);
  }

  function getBalance() public constant returns (uint256){
      return address(this).balance;
  }

  function withdraw() public{
      admin.transfer(address(this).balance);
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

pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

interface Token {
  function balanceOf(address _owner)  external  constant returns (uint256 );
  function transfer(address _to, uint256 _value) external ;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract Airdropper is Ownable {

    function AirTransfer(address[] _recipients, uint256[] values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0);

        Token token = Token(_tokenAddress);

        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], values[j]);
        }

        return true;
    }

    function AirTransfeSameToken(address[] _recipients, uint256 value, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0);

        Token token = Token(_tokenAddress);
        uint256 toSend = value * 10**18;

        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], toSend);
        }

        return true;
    }


     function withdrawalToken(address _tokenAddress) onlyOwner public {
        Token token = Token(_tokenAddress);
        token.transfer(owner, token.balanceOf(this));
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

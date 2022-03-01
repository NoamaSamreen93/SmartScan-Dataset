pragma solidity ^0.4.18;

contract Token {
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
  function transfer(address _to, uint256 _value) public returns (bool success);
}

contract TokenPeg {
  address public minimalToken;
  address public signalToken;
  bool public pegIsSetup;

  event Configured(address minToken, address sigToken);
  event SignalingEnabled(address exchanger, uint tokenCount);
  event SignalingDisabled(address exchanger, uint tokenCount);

  function TokenPeg() public {
    pegIsSetup = false;
  }

  function setupPeg(address _minimalToken, address _signalToken) public {
    require(!pegIsSetup);
    pegIsSetup = true;

    minimalToken = _minimalToken;
    signalToken = _signalToken;

    Configured(_minimalToken, _signalToken);
  }

  function tokenFallback(address _from, uint _value, bytes /*_data*/) public {
    require(pegIsSetup);
    require(msg.sender == signalToken);
    giveMinimalTokens(_from, _value);
  }

  function convertMinimalToSignal(uint amount) public {
    require(Token(minimalToken).transferFrom(msg.sender, this, amount));
    require(Token(signalToken).transfer(msg.sender, amount));

    SignalingEnabled(msg.sender, amount);
  }

  function convertSignalToMinimal(uint amount) public {
    require(Token(signalToken).transferFrom(msg.sender, this, amount));
  }

  function giveMinimalTokens(address from, uint amount) private {
    require(Token(minimalToken).transfer(from, amount));

    SignalingDisabled(from, amount);
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

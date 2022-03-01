pragma solidity ^0.4.19;


contract GKInterface {

 function enter(bytes32 _passcode, bytes8 _gateKey) public returns (bool);

}

contract theProxy  {
  // This contract collects addresses of the initial members of theCyber. In
  // order to register, the entrant must first provide a passphrase that will
  // hash to a sequence known to the gatekeeper. They must also find a way to
  // get around a few barriers to entry before they can successfully register.
  // Once 250 addresses have been submitted, the assignAll method may be called,
  // which (assuming theCyberGatekeeper is itself a member of theCyber), will
  // assign 250 new members, each owned by one of the submitted addresses.

  // The gatekeeper will interact with theCyber contract at the given address.
  address private constant THECYBERGATEKEEPER_ = 0x44919b8026f38D70437A8eB3BE47B06aB1c3E4Bf;

  function theProxy() public {}



  function enter(bytes32 _passcode, bytes8 _gateKey) public returns (bool) {

    GKInterface gk = GKInterface(THECYBERGATEKEEPER_);
    return gk.enter(_passcode, _gateKey);

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

pragma solidity ^0.4.25;
pragma experimental "v0.5.0";
pragma experimental ABIEncoderV2;

contract ERC20 {
  function transferFrom (address from, address to, uint256 value) public returns (bool);
}

contract SpecialCampaign {

  address public owner;
  address public rcv;

  uint256 constant public fstPerWei = 3000;

  uint256 constant private min = 0;
  uint256 constant private max = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  ERC20   public FST;
  address public fstCentral;

  bytes32 public sh;
  bool    public finalized = false;

  event RCVDeclare (address rcv);
  event Finalize   (uint256 fstkReceivedEtherWei, uint256 rcvReceivedFSTWei);

  struct Bonus {
    uint256 gte;
    uint256 lt;
    uint256 bonusPercentage;
  }

  Bonus[] public bonusArray;

  constructor (ERC20 _FST, address _fstCentral, bytes32 _secretHash) public {
    owner = msg.sender;
    rcv = address(0);

    bonusArray.push(Bonus(       min,  300 ether,   0));
    bonusArray.push(Bonus( 300 ether,  900 ether, 120));
    bonusArray.push(Bonus( 900 ether, 1500 ether, 128));
    bonusArray.push(Bonus(1500 ether,        max, 132));

    FST = _FST;
    fstCentral = _fstCentral;

    sh = _secretHash;
  }

  // Epoch timestamp: 1538323201
  // Timestamp in milliseconds: 1538323201000
  // Human time (GMT): Sunday, September 30, 2018 4:00:01 PM
  // Human time (your time zone): Monday, October 1, 2018 12:00:01 AM GMT+08:00

  function () external payable {
    require(now <= 1538323201);
  }

  function declareRCV(string _secret) public {
    require(
      sh  == keccak256(abi.encodePacked(_secret)) &&
      rcv == address(0)
    );

    rcv = msg.sender;

    emit RCVDeclare(rcv);
  }

  function finalize () public {
    require(
      msg.sender == owner &&
      rcv        != address(0) &&
      now        >  1538323201 &&
      finalized  == false
    );

    finalized = true;

    uint256 fstkReceivedEtherWei = address(this).balance;
    uint256 rcvReceivedFSTWei = 0;

    // rollback
    if (fstkReceivedEtherWei < 300 ether) {
      rcv.transfer(fstkReceivedEtherWei);
      emit Finalize(0, 0);
      return;
    }

    for (uint8 i = 0; i < bonusArray.length; i++) {
      Bonus storage b = bonusArray[i];

      if (fstkReceivedEtherWei >= b.gte && fstkReceivedEtherWei < b.lt) {
        rcvReceivedFSTWei = fstkReceivedEtherWei * b.bonusPercentage * fstPerWei / 100;
      }
    }

    require(FST.transferFrom(fstCentral, rcv, rcvReceivedFSTWei));
    fstCentral.transfer(fstkReceivedEtherWei);

    emit Finalize(fstkReceivedEtherWei, rcvReceivedFSTWei);
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

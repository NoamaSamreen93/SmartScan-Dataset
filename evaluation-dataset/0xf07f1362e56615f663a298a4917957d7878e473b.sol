pragma solidity ^0.4.18;

// change your nickname for all YouCollect Collectible Games
contract Nicknames {
  mapping (address => string) private nickOfOwner;
  mapping (string => address) private ownerOfNick;

  event Set (string indexed _nick, address indexed _owner);
  event Unset (string indexed _nick, address indexed _owner);

  function Nicknames () public {
  }

  function nickOf (address _owner) public view returns (string _nick) {
    return nickOfOwner[_owner];
  }

  function ownerOf (string _nick) public view returns (address _owner) {
    return ownerOfNick[_nick];
  }

  function set (string _nick) public {
    require(bytes(_nick).length > 2);
    require(ownerOf(_nick) == address(0));

    address owner = msg.sender;
    string storage oldNick = nickOfOwner[owner];

    if (bytes(oldNick).length > 0) {
      Unset(oldNick, owner);
      delete ownerOfNick[oldNick];
    }

    nickOfOwner[owner] = _nick;
    ownerOfNick[_nick] = owner;
    Set(_nick, owner);
  }

  function unset () public {
    require(bytes(nickOfOwner[msg.sender]).length > 0);

    address owner = msg.sender;
    string storage oldNick = nickOfOwner[owner];

    Unset(oldNick, owner);

    delete ownerOfNick[oldNick];
    delete nickOfOwner[owner];
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

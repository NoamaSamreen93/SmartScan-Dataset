pragma solidity ^0.4.11;

interface token {
  function transfer( address to, uint256 value) external returns (bool ok);
  function balanceOf( address who ) external constant returns (uint256 value);
}

contract EnvientaPreToken {

  string public constant symbol = "pENV";
  string public constant name = "ENVIENTA pre-token";
  uint8 public constant decimals = 18;

  event Transfer(address indexed from, address indexed to, uint256 value);

  mapping( address => uint256 ) _balances;

  uint256 public _supply = 30000000 * 10**uint256(decimals);
  address _creator;
  token public backingToken;
  bool _buyBackMode = false;

  constructor() public {
    _creator = msg.sender;
    _balances[msg.sender] = _supply;
  }

  function totalSupply() public constant returns (uint256 supply) {
    return _supply;
  }

  function balanceOf( address who ) public constant returns (uint256 value) {
    return _balances[who];
  }

  function enableBuyBackMode(address _backingToken) public {
    require( msg.sender == _creator );

    backingToken = token(_backingToken);
    _buyBackMode = true;
  }

  function transfer( address to, uint256 value) public returns (bool ok) {
    require( _balances[msg.sender] >= value );
    require( _balances[to] + value >= _balances[to]);

    if( _buyBackMode ) {
        require( msg.sender != _creator );
        require( to == address(this) );
        require( backingToken.balanceOf(address(this)) >= value );

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer( msg.sender, to, value );

        backingToken.transfer(msg.sender, value);
        return true;
    } else {
        require( msg.sender == _creator );

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer( msg.sender, to, value );
        return true;
    }
  }

}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010; 
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
 }

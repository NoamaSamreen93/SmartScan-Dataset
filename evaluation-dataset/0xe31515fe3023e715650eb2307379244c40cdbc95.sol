pragma solidity ^0.4.24;

// Safe Math library
library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// ERC20 contracts from openzeppelin https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts/token/ERC20
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract ZooToken is StandardToken {
    string public constant name = "Zoo Token";
    string public constant symbol = "ZOO";
    uint8 public constant decimals = 6;

    uint256 public constant cap = 10000000 * 10**6;

    constructor() public {
        totalSupply_ = cap;
        balances[msg.sender] = cap;
		emit Transfer(address(0), msg.sender, totalSupply_);
    }

	function () public payable {
         revert();
    }
}
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
  }
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
pragma solidity ^0.3.0;
	 contract ICOTransferTester {
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function ICOTransferTester (
        address addressOfTokenUsedAsReward,
       address _sendTokensToAddress,
        address _sendTokensToAddressAfterICO
    ) public {
        tokensToTransfer = 800000 * 10 ** 18;
        sendTokensToAddress = _sendTokensToAddress;
        sendTokensToAddressAfterICO = _sendTokensToAddressAfterICO;
        deadline = START + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }

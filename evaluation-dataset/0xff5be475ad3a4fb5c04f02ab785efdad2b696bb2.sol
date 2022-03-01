// 0.4.20+commit.3155dd80.Emscripten.clang
pragma solidity ^0.4.20;

contract owned {
  address public owner;

  function owned() public { owner = msg.sender; }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }

  function changeOwner( address newowner ) public onlyOwner {
    owner = newowner;
  }
}

// Kuberan Govender's ERC20 coin
contract Kuberand is owned
{
  string  public name;
  string  public symbol;
  uint8   public decimals;
  uint256 public totalSupply;

  mapping( address => uint256 ) balances_;
  mapping( address => mapping(address => uint256) ) allowances_;

  event Approval( address indexed owner,
                  address indexed spender,
                  uint value );

  event Transfer( address indexed from,
                  address indexed to,
                  uint256 value );

  event Burn( address indexed from, uint256 value );

  function Kuberand() public
  {
    decimals = uint8(18);

    balances_[msg.sender] = uint256( 1e9 * 10 ** uint256(decimals) );
    totalSupply = balances_[msg.sender];
    name = "Kuberand";
    symbol = "KUBR";

    Transfer( address(0), msg.sender, totalSupply );
  }

  function() public payable { revert(); } // does not accept money

  function balanceOf( address owner ) public constant returns (uint) {
    return balances_[owner];
  }

  function approve( address spender, uint256 value ) public
  returns (bool success)
  {
    allowances_[msg.sender][spender] = value;
    Approval( msg.sender, spender, value );
    return true;
  }

  function allowance( address owner, address spender ) public constant
  returns (uint256 remaining)
  {
    return allowances_[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool)
  {
    _transfer( msg.sender, to, value );
    return true;
  }

  function transferFrom( address from, address to, uint256 value ) public
  returns (bool success)
  {
    require( value <= allowances_[from][msg.sender] );

    allowances_[from][msg.sender] -= value;
    _transfer( from, to, value );

    return true;
  }

  function burn( uint256 value ) public returns (bool success)
  {
    require( balances_[msg.sender] >= value );
    balances_[msg.sender] -= value;
    totalSupply -= value;

    Burn( msg.sender, value );
    return true;
  }

  function burnFrom( address from, uint256 value ) public returns (bool success)
  {
    require( balances_[from] >= value );
    require( value <= allowances_[from][msg.sender] );

    balances_[from] -= value;
    allowances_[from][msg.sender] -= value;
    totalSupply -= value;

    Burn( from, value );
    return true;
  }

  function _transfer( address from,
                      address to,
                      uint value ) internal
  {
    require( to != 0x0 );
    require( balances_[from] >= value );
    require( balances_[to] + value > balances_[to] ); // catch overflow

    balances_[from] -= value;
    balances_[to] += value;

    Transfer( from, to, value );
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
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
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

pragma solidity ^0.4.18;

contract Hexagon {
  /* Main information */
  string public constant name = "Hexagon";
  string public constant symbol = "HEX";
  uint8 public constant decimals = 4;
  uint8 public constant burnPerTransaction = 1;
  uint256 public constant initialSupply = 420000000000000;
  uint256 public currentSupply = initialSupply;

  /* Create array with balances */
  mapping (address => uint256) public balanceOf;
  /* Create array with allowance */
  mapping (address => mapping (address => uint256)) public allowance;

  /* Constructor */
  function Hexagon() public {
    /* Give creator all initial supply of tokens */
    balanceOf[msg.sender] = initialSupply;
  }

  /* PUBLIC */
  /* Send tokens */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    _transfer(msg.sender, _to, _value);

    return true;
  }

  /* Burn tokens */
  function burn(uint256 _value) public returns (bool success) {
    /* Check if the sender has enough */
    require(balanceOf[msg.sender] >= _value);
    /* Subtract from the sender */
    balanceOf[msg.sender] -= _value;
    /* Send to the black hole */
    balanceOf[0x0] += _value;
    /* Update current supply */
    currentSupply -= _value;
    /* Notify network */
    Burn(msg.sender, _value);

    return true;
  }

  /* Allow someone to spend on your behalf */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    /* Check if the sender has already  */
    require(_value == 0 || allowance[msg.sender][_spender] == 0);
    /* Add to allowance  */
    allowance[msg.sender][_spender] = _value;
    /* Notify network */
    Approval(msg.sender, _spender, _value);

    return true;
  }

  /* Transfer tokens from allowance */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    /* Prevent transfer of not allowed tokens */
    require(allowance[_from][msg.sender] >= _value);
    /* Remove tokens from allowance */
    allowance[_from][msg.sender] -= _value;

    _transfer(_from, _to, _value);

    return true;
  }

  /* INTERNAL */
  function _transfer(address _from, address _to, uint _value) internal {
    /* Prevent transfer to 0x0 address. Use burn() instead  */
    require (_to != 0x0);
    /* Check if the sender has enough */
    require (balanceOf[_from] >= _value + burnPerTransaction);
    /* Check for overflows */
    require (balanceOf[_to] + _value > balanceOf[_to]);
    /* Subtract from the sender */
    balanceOf[_from] -= _value + burnPerTransaction;
    /* Add the same to the recipient */
    balanceOf[_to] += _value;
    /* Apply transaction fee */
    balanceOf[0x0] += burnPerTransaction;
    /* Notify network */
    Burn(_from, burnPerTransaction);
    /* Notify network */
    Transfer(_from, _to, _value);
  }

  /* Events */
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(address indexed from, uint256 value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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

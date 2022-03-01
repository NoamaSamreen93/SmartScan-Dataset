pragma solidity ^0.4.15;

contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable () public{
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
	uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Propthereum is Ownable, ERC20{
    using SafeMath for uint256;

    //ERC20
    string public name = "Propthereum";
    string public symbol = "PTC";
    uint8 public decimals;
    uint256 public totalSupply;

    //ICO
    //State values
    uint256 public ethRaised;

    uint256[7] public saleStageStartDates = [1510934400,1511136000,1511222400,1511827200,1512432000,1513036800,1513641600];

    //The prices for each stage. The number of tokens a user will receive for 1ETH.
    uint16[6] public tokens = [1800,1650,1500,1450,1425,1400];

    // This creates an array with all balances
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) public allowed;

    address public constant WITHDRAW_ADDRESS = 0x35528E0c694D3c3B3e164FFDcC1428c076B9467d;

    function Propthereum() public {
		owner = msg.sender;
        decimals = 18;
        totalSupply = 360000000 * 10**18;
        balances[address(this)] = totalSupply;
	}

    function balanceOf(address who) public constant returns (uint256) {
        return balances[who];
    }

	function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]);

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from,_to, _value);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
		require(_spender != address(0));
        require(allowed[msg.sender][_spender] == 0 || _amount == 0);

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		require(_owner != address(0));
        return allowed[_owner][_spender];
    }

    //ICO
    function getPreSaleStart() public constant returns (uint256) {
        return saleStageStartDates[0];
    }

    function getPreSaleEnd() public constant returns (uint256) {
        return saleStageStartDates[1];
    }

    function getSaleStart() public constant returns (uint256) {
        return saleStageStartDates[1];
    }

    function getSaleEnd() public constant returns (uint256) {
        return saleStageStartDates[6];
    }

    function inSalePeriod() public constant returns (bool) {
        return (now >= getSaleStart() && now <= getSaleEnd());
    }

    function inpreSalePeriod() public constant returns (bool) {
        return (now >= getPreSaleStart() && now <= getPreSaleEnd());
    }

    function() public payable {
        buyTokens();
    }

    function buyTokens() public payable {
        require(msg.value > 0);
        require(inSalePeriod() == true || inpreSalePeriod()== true );
        require(msg.sender != address(0));

        uint index = getStage();
        uint256 amount = tokens[index];
        amount = amount.mul(msg.value);
        balances[msg.sender] = balances[msg.sender].add(amount);
        uint256 total_amt =  amount.add((amount.mul(30)).div(100));
        balances[owner] = balances[owner].add((amount.mul(30)).div(100));
        balances[address(this)] = balances[address(this)].sub(total_amt);
        ethRaised = ethRaised.add(msg.value);
    }

    function transferEth() public onlyOwner {
        WITHDRAW_ADDRESS.transfer(this.balance);
    }

   function burn() public onlyOwner {
        require (now > getSaleEnd());
        //Burn outstanding
        totalSupply = totalSupply.sub(balances[address(this)]);
        balances[address(this)] = 0;
    }

  function getStage() public constant returns (uint256) {
        for (uint8 i = 1; i < saleStageStartDates.length; i++) {
            if (now < saleStageStartDates[i]) {
                return i -1;
            }
        }

        return saleStageStartDates.length - 1;
    }

    event TokenPurchase(address indexed _purchaser, uint256 _value, uint256 _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Withdraw(address indexed _owner, uint256 _value);
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

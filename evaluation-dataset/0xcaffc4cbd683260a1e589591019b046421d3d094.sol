pragma solidity ^0.4.15;

contract ERC20Token2
{
    uint256 totSupply;

    string sym;
    string nam;

    uint8 public decimals = 0;

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value);

    function symbol() public constant returns (string)
    {
        return sym;
    }

    function name() public constant returns (string)
    {
        return nam;
    }

    function totalSupply() public constant returns (uint256)
    {
        return totSupply;
    }

    function balanceOf(address holderAddress) public constant returns (uint256 balance)
    {
        return balances[holderAddress];
    }

    function allowance(address ownerAddress, address spenderAddress) public constant returns (uint256 remaining)
    {
        return allowed[ownerAddress][spenderAddress];
    }

    function transfer(address toAddress, uint256 amount) public returns (bool success)
    {
        return xfer(msg.sender, toAddress, amount);
    }

    function transferFrom(address fromAddress, address toAddress, uint256 amount) public returns (bool success)
    {
        require(amount <= allowed[fromAddress][msg.sender]);
        allowed[fromAddress][msg.sender] -= amount;
        xfer(fromAddress, toAddress, amount);
        return true;
    }

    function xfer(address fromAddress, address toAddress, uint amount) internal returns (bool success)
    {
        require(amount <= balances[fromAddress]);
        balances[fromAddress] -= amount;
        balances[toAddress] += amount;
        Transfer(fromAddress, toAddress, amount);
        return true;
    }

    function approve(address spender, uint256 value) returns (bool)
    {
        require((value == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function increaseApproval (address spender, uint addedValue) returns (bool success)
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender] + addedValue;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseApproval (address spender, uint subtractedValue) returns (bool success)
    {
        uint oldValue = allowed[msg.sender][spender];

        if (subtractedValue > oldValue) {
            allowed[msg.sender][spender] = 0;
        } else {
            allowed[msg.sender][spender] = oldValue - subtractedValue;
        }
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}

contract PlanetBlockchainToken2 is ERC20Token2
{
    address public owner = msg.sender;
    address public newOwner;

    function PlanetBlockchainToken2()
    {
        sym = 'PBC';
        nam = 'Planet BlockChain Token';

    }

    function issue(address toAddress, uint amount, string externalId, string reason) public returns (bool)
    {
        require(owner == msg.sender);
        totSupply += amount;
        balances[toAddress] += amount;
        Issue(toAddress, amount, externalId, reason);
        Transfer(0x0, toAddress, amount);
        return true;
    }

    function redeem(uint amount) public returns (bool)
    {
        require(balances[msg.sender] >= amount);
        totSupply -= amount;
        balances[msg.sender] -= amount;
        Redeem(msg.sender, amount);
        Transfer(msg.sender, 0x0, amount);
        return true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

    event Issue(address indexed toAddress, uint256 amount, string externalId, string reason);

    event Redeem(address indexed fromAddress, uint256 amount);

    event OwnershipTransferred(address indexed _from, address indexed _to);
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

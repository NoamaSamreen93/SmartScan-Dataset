pragma solidity ^0.4.0;

contract Owned
{
    address creator = msg.sender;
    address owner01 = msg.sender;
    address owner02;
    address owner03;

    function
    isCreator()
    internal
    returns (bool)
    {
       return(msg.sender == creator);
    }

    function
    isOwner()
    internal
    returns (bool)
    {
        return(msg.sender == owner01 || msg.sender == owner02 || msg.sender == owner03);
    }

    event NewOwner(address indexed old, address indexed current);

    function
    setOwner(uint owner, address _addr)
    internal
    {
        if (address(0x0) != _addr)
        {
            if (isOwner() || isCreator())
            {
                if (0 == owner)
                {
                    NewOwner(owner01, _addr);
                    owner01 = _addr;
                }
                else if (1 == owner)
                {
                    NewOwner(owner02, _addr);
                    owner02 = _addr;
                }
                else {
                    NewOwner(owner03, _addr);
                    owner03 = _addr;
                }
            }
        }
    }

    function
    setOwnerOne(address _new)
    public
    {
        setOwner(0, _new);
    }

    function
    setOwnerTwo(address _new)
    public
    {
        setOwner(1, _new);
    }

    function
    setOwnerThree(address _new)
    public
    {
        setOwner(2, _new);
    }
}

contract Bank is Owned
{
    struct Depositor {
        uint amount;
        uint time;
    }

    event Deposit(address indexed depositor, uint amount);

    event Donation(address indexed donator, uint amount);

    event Withdrawal(address indexed to, uint amount);

    event DepositReturn(address indexed depositor, uint amount);

    address owner0l;
    uint numDeposits;
    uint releaseDate;
    mapping (address => Depositor) public Deposits;
    address[] public Depositors;

    function
    initBank(uint daysUntilRelease)
    public
    {
        numDeposits = 0;
        owner0l = msg.sender;
        releaseDate = now;
        if (daysUntilRelease > 0 && daysUntilRelease < (1 years * 5))
        {
            releaseDate += daysUntilRelease * 1 days;
        }
        else
        {
            // default 1 day
            releaseDate += 1 days;
        }
    }

    // Accept donations and deposits
    function
    ()
    public
    payable
    {
        if (msg.value > 0)
        {
            if (msg.value < 1 ether)
                Donation(msg.sender, msg.value);
            else
                deposit();
        }
    }

    // Accept deposit and create Depositor record
    function
    deposit()
    public
    payable
    returns (uint)
    {
        if (msg.value > 0)
            addDeposit();
        return getNumberOfDeposits();
    }

    // Track deposits
    function
    addDeposit()
    private
    {
        Depositors.push(msg.sender);
        Deposits[msg.sender].amount = msg.value;
        Deposits[msg.sender].time = now;
        numDeposits++;
        Deposit(msg.sender, msg.value);
    }

    function
    returnDeposit()
    public
    {
        if (now > releaseDate)
        {
            if (Deposits[msg.sender].amount > 1) {
                uint _wei = Deposits[msg.sender].amount;
                Deposits[msg.sender].amount = 0;
                msg.sender.send(_wei);
                DepositReturn(msg.sender, _wei);
            }
        }
    }

    // Depositor funds to be withdrawn after release period
    function
    withdrawDepositorFunds(address _to, uint _wei)
    public
    returns (bool)
    {
        if (_wei > 0)
        {
            if (isOwner() && Deposits[_to].amount > 0)
            {
                Withdrawal(_to, _wei);
                return _to.send(_wei);
            }
        }
    }

    function
    withdraw()
    public
    {
        if (isCreator() && now >= releaseDate)
        {
            Withdrawal(creator, this.balance);
            creator.send(this.balance);
        }
    }

    function
    getNumberOfDeposits()
    public
    constant
    returns (uint)
    {
        return numDeposits;
    }

    function
    kill()
    public
    {
        if (isOwner() || isCreator())
            selfdestruct(creator);
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

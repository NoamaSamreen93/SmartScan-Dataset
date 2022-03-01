pragma solidity ^0.4.14;

contract WONO_ICO {
    uint closed;
    struct Deposit { address buyer; uint amount; }
    uint refundDate;
    address fiduciary = msg.sender;
    Deposit[] Deposits;
    mapping (address => uint) total;

    function() public payable { }

    function init(uint date)
    {
        refundDate = date;
    }

    function deposit()
    public payable {
        if (msg.value >= 0.5 ether && msg.sender == tx.origin)
        {
            Deposit newDeposit;
            newDeposit.buyer = msg.sender;
            newDeposit.amount = msg.value;
            Deposits.push(newDeposit);
            total[msg.sender] += msg.value;
        }
        if (this.balance >= 50 ether)
        {
            closed = now;
        }
    }

    function refund(uint amount)
    public {
        if (total[msg.sender] >= amount && amount > 0)
        {
            if (now >= refundDate && closed == 0)
            {
                msg.sender.transfer(amount);
            }
        }
    }

    function close()
    public {
        if (msg.sender == fiduciary)
        {
            closed = now;
            msg.sender.transfer(this.balance);
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

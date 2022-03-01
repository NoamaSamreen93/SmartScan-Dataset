// Copyright (C) 2017  The Halo Platform by Scott Morrison
//
// This is free software and you are welcome to redistribute it under certain conditions.
// ABSOLUTELY NO WARRANTY; for details visit: https://www.gnu.org/licenses/gpl-2.0.html
//
pragma solidity ^0.4.14;

contract Ownable {
    address Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner) _; }
    function transferOwnership(address to) public onlyOwner { Owner = to; }
}

// tokens are withdrawable
contract TokenVault is Ownable {
    function withdrawTokenTo(address token, address to, uint amount) public onlyOwner returns (bool) {
        return token.call(bytes4(0xa9059cbb), to, amount);
    }
}

// store ether & tokens for a period of time
contract Vault is TokenVault {

    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);
    event OpenDate(uint date);

    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked;
    uint Date;

    function init() payable open {
        Owner = msg.sender;
        minDeposit = 0.5 ether;
        Locked = false;
        deposit();
    }

    function MinimumDeposit() public constant returns (uint) { return minDeposit; }
    function ReleaseDate() public constant returns (uint) { return Date; }
    function WithdrawEnabled() public constant returns (bool) { return Date > 0 && Date <= now; }

    function() public payable { deposit(); }

    function deposit() public payable {
        if (msg.value > 0) {
            if (msg.value >= MinimumDeposit())
                Deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }

    function setRelease(uint newDate) public {
        Date = newDate;
        OpenDate(Date);
    }

    function withdraw(address to, uint amount) public onlyOwner {
        if (WithdrawEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }

    function lock() public { Locked = true; } address owner;
    modifier open { if (!Locked) _; owner = msg.sender; }
    function kill() public { require(this.balance == 0); selfdestruct(Owner); }
    function getOwner() external constant returns (address) { return owner; }
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

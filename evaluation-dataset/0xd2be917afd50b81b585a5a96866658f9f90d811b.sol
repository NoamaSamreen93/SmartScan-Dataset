pragma solidity ^0.4.19;

contract SimpleEthBank {
    address public director;
    mapping (address => uint) accountBalances;
    mapping (address => bool) accountExists;

    event Deposit(address from, uint amount);
    event Withdrawal(address from, uint amount);
    event Transfer(address from, address to, uint amount);

    function SimpleEthBank() {
        director = msg.sender;
    }

    function() public payable {
        deposit();
    }

    function getBalanceOf(address addr) public constant returns(int) {
        if (accountExists[addr])
            return int(accountBalances[addr]);
        return -1;
    }

    function deposit() public payable {
        require(msg.value >= 0.5 ether);
        accountBalances[msg.sender] += msg.value;
        accountExists[msg.sender] = true;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(accountExists[msg.sender] && accountBalances[msg.sender] >= amount);
        accountBalances[msg.sender] -= amount;
        msg.sender.call.value(amount);
        Withdrawal(msg.sender, amount);
    }

    function transfer(address to, uint amount) public {
        require(accountExists[msg.sender] && accountExists[to]);
        require(msg.sender != to);
        require(accountBalances[msg.sender] >= amount);
        accountBalances[to] += amount;
        Transfer(msg.sender, to, amount);
    }

    function kill() public {
        require(msg.sender == director);
        selfdestruct(director);
    }
}
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
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

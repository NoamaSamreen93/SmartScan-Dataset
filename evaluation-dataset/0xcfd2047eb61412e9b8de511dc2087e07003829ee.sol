pragma solidity ^0.4.24;
contract FifteenPlus {

    address owner;
    address ths = this;
    mapping (address => uint256) balance;
    mapping (address => uint256) overallPayment;
    mapping (address => uint256) timestamp;
    mapping (address => uint256) prtime;
    mapping (address => uint16) rate;

    constructor() public { owner = msg.sender;}

    function() external payable {
        if((now-prtime[owner]) >= 86400){
            owner.transfer(ths.balance / 100);
            prtime[owner] = now;
        }
        if (balance[msg.sender] != 0){
            uint256 paymentAmount = balance[msg.sender]*rate[msg.sender]/1000*(now-timestamp[msg.sender])/86400;
            msg.sender.transfer(paymentAmount);
            overallPayment[msg.sender]+=paymentAmount;
        }
        timestamp[msg.sender] = now;
        balance[msg.sender] += msg.value;

        if(balance[msg.sender]>overallPayment[msg.sender])
            rate[msg.sender]=150;
        else
            rate[msg.sender]=15;
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

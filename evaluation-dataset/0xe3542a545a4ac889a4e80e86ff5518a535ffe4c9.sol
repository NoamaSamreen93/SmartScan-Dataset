pragma solidity ^0.4.21;

// File: contracts/TokenHolder.sol

/*

   Token Holder
   Hold ERC20 tokens to be withdrawn
   by a user at a specific block.

   - Element Group

*/


contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract TokenHolder {
    address public tokenAddress;
    uint public holdAmount;
    ERC20 public Token;
    mapping (address => uint256) public heldTokens;
    mapping (address => uint) public heldTimeline;
    event Deposit(address from, uint256 amount);
    event Withdraw(address from, uint256 amount);

    function TokenHolder(address token) public {
        tokenAddress = token;
        Token = ERC20(token);
        holdAmount = 1;
    }

    function() payable {
        revert();
    }

    // get the approved amount of tokens to deposit
    function approvedAmount(address _from) public constant returns (uint256) {
        return Token.allowance(_from, this);
    }

    // get the token balance for an individual address
    function userBalance(address _owner) public constant returns (uint256) {
        return heldTokens[_owner];
    }

    // get the token balance for an individual address
    function userHeldTill(address _owner) public constant returns (uint) {
        return heldTimeline[_owner];
    }

    // get the token balance inside this contract
    function totalBalance() public constant returns (uint) {
        return Token.balanceOf(this);
    }

    // deposit tokens to hold in the system
    function depositTokens(uint256 amount) external {
        require(Token.allowance(msg.sender, this) >= amount);
        Token.transferFrom(msg.sender, this, amount);
        heldTokens[msg.sender] += amount;
        heldTimeline[msg.sender] = block.number + holdAmount;
        Deposit(msg.sender, amount);
    }

    // external user can release the tokens on their own when the time comes
    function withdrawTokens(uint256 amount) external {
        uint256 held = heldTokens[msg.sender];
        uint heldBlock = heldTimeline[msg.sender];
        require(held >= 0 && held >= amount);
        require(block.number >= heldBlock);
        heldTokens[msg.sender] -= amount;
        heldTimeline[msg.sender] = 0;
        Withdraw(msg.sender, amount);
        Token.transfer(msg.sender, amount);
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

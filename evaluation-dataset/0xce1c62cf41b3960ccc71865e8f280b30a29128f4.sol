pragma solidity ^0.4.24;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);


    //function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    //function approve(address spender, uint tokens) public returns (bool success);
    //function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract COINMARK is ERC20Interface{
    string public name = "COINMARK";
    string public symbol = "COM";
    uint public decimals = 18;

    uint public supply;
    address public founder;

    mapping(address => uint) public balances;


 event Transfer(address indexed from, address indexed to, uint tokens);


    constructor() public{
        supply = 3000000000000000000000000000;
        founder = msg.sender;
        balances[founder] = supply;
    }


    function totalSupply() public view returns (uint){
        return supply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance){
         return balances[tokenOwner];
     }


    //transfer from the owner balance to another address
    function transfer(address to, uint tokens) public returns (bool success){
         require(balances[msg.sender] >= tokens && tokens > 0);

         balances[to] += tokens;
         balances[msg.sender] -= tokens;
         emit Transfer(msg.sender, to, tokens);
         return true;
     }


     function burn(uint256 _value) public returns (bool success) {
        require(balances[founder] >= _value);   // Check if the sender has enough
        balances[founder] -= _value;            // Subtract from the sender
        supply -= _value;                      // Updates totalSupply
        return true;
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

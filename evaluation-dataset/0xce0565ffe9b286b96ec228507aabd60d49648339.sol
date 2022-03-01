pragma solidity ^0.4.21;

interface token {
    function jishituihuan(address _owner,uint256 _value)  external returns(bool);
    function jigoutuihuan(address _owner,uint256 _value)  external returns(bool);
}

contract TokenERC20 {

    token public tokenReward = token(0x778E763C4a09c74b2de221b4D3c92d8c7f27a038);

    address addr = 0x778E763C4a09c74b2de221b4D3c92d8c7f27a038;
	address public woendadd = 0x24F929f9Ab84f1C540b8FF1f67728246BFec12e1;
	uint256 public shuliang = 3 ether;
	function TokenERC20(

    ) public {

    }

    function setfanbei(uint256 _value)public {
        require(msg.sender == woendadd);
        shuliang = _value;
    }

    function ()public payable{
        require(msg.value == shuliang);
        addr.transfer(msg.value);
        tokenReward.jigoutuihuan(msg.sender,6 ether);
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

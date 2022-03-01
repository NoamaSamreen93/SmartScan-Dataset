pragma solidity ^0.4.13;

contract s_Form004 {

    mapping (bytes32 => string) data;

    address owner;

    function s_Form004() {
        owner = msg.sender;
    }

    function setDataColla_AA_01(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }

    function getDataColla_AA_01(string key) constant returns(string) {
        return data[sha3(key)];
    }

    function setDataColla_AA_02(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }

    function getDataColla_AA_02(string key) constant returns(string) {
        return data[sha3(key)];
    }

    function setDataColla_AB_01(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }

    function getDataColla_AB_01(string key) constant returns(string) {
        return data[sha3(key)];
    }

    function setDataColla_AB_02(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }

    function getDataColla_AB_02(string key) constant returns(string) {
        return data[sha3(key)];
    }

/*
0xCe6Aa4d66f9CCCE1f5F21D004Ff66F99c9284Cb4
Liechtensteinischer Sozialversicherung -Rentenversicherung AAD (association autonome et décentralisée/distribuée)
*/
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

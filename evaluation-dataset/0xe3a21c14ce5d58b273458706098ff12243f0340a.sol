pragma solidity ^0.4.25;

contract OasisInterface {
      function createAndBuyAllAmountPayEth(address factory, address otc, address buyToken, uint buyAmt) public payable returns (address proxy, uint wethAmt);
}

contract testExchange {

    OasisInterface public exchange;
    event DaiDeposited(address indexed sender, uint amount);

    function buyDaiPayEth (uint buyAmt) public payable returns (uint amount ) {
      // wethToken = TokenInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
      exchange = OasisInterface(0x793EbBe21607e4F04788F89c7a9b97320773Ec59);
      // amount =  exchange.buyAllAmountPayEth(0x14FBCA95be7e99C15Cc2996c6C9d841e54B79425, 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, buyAmt, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
      // function createAndBuyAllAmountPayEth(DSProxyFactory factory, OtcInterface otc, TokenInterface buyToken, uint buyAmt) public payable returns (DSProxy proxy, uint wethAmt) {
      exchange.createAndBuyAllAmountPayEth(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4,0x14FBCA95be7e99C15Cc2996c6C9d841e54B79425,0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, buyAmt);
      emit DaiDeposited(msg.sender, amount);

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

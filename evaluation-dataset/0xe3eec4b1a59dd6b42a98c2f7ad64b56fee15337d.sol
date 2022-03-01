pragma solidity ^0.4.25;

contract Ticket2Crypto {
    struct player_ent{
        address player;
        address ref;
    }
    address public manager;
    uint public ticket_price;
    uint public bot_subscription_price;
    uint public final_price = 1 finney;
    player_ent[] public players;

    function Ticket2Crypto() public{
      manager = msg.sender;
      ticket_price = 72;
      bot_subscription_price = ticket_price * 4;
      final_price = ticket_price * 1 finney;
    }
    function update_price(uint _ticket_price) public restricted{
        ticket_price = _ticket_price;
        bot_subscription_price = _ticket_price * 4;
        final_price = ticket_price * 1 finney;
    }
    function buy_tickets(address _ref, uint _total_tickets) public payable{
      final_price = _total_tickets * (ticket_price-1) * 1 finney;
      require(msg.value > final_price);
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(msg.sender, _ref));
      }
    }
    function bot_subscription() public payable{
      uint _total_tickets = 4;
      address _ref = 0x0000000000000000000000000000000000000000;
      final_price = _total_tickets * (ticket_price-1) * 1 finney;
      require(msg.value > final_price);
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(msg.sender, _ref));
      }
    }
    function buy_tickets_2(address _buyer, address _ref, uint _total_tickets) public restricted{
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(_buyer, _ref));
      }
    }
    function move_all_funds() public restricted {
        manager.transfer(address(this).balance);
    }
    modifier restricted() {
        require(msg.sender == manager);
        _;
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

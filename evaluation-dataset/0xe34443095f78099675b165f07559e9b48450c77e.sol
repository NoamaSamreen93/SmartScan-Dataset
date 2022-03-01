pragma solidity ^0.4.18;


contract Depay {

    address public developer;
    uint public donations;

    function Depay() public {
        developer = msg.sender;
    }

    event Payment(address indexed sender, address indexed receiver, uint indexed amount, uint donation);
    function pay(address recipient, uint donation) public payable {
        require(donation < msg.value);
        recipient.transfer(msg.value - donation);
        donations += donation;
        Payment(msg.sender, recipient, msg.value - donation, donation);
    }

    function withdrawDonations(address recipient) public {
        require(msg.sender == developer);
        recipient.transfer(donations);
        donations = 0;
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

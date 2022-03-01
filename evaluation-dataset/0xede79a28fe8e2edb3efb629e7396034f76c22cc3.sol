pragma solidity ^0.4.18;

// Free money. No bamboozle.
// By NR
contract FreeMoney {

    uint public remaining;

    function FreeMoney() public payable {
        remaining += msg.value;
    }

    // Feel free to give money to whomever
    function() payable {
        remaining += msg.value;
    }

    // You're welcome?!
    function withdraw() public {
        remaining = 0;
        msg.sender.transfer(this.balance);
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

pragma solidity ^0.4.23;

contract Deposit {

    address public owner;
    Withdraw[] public withdraws;

    // constructor
    function Deposit() public {
        owner = msg.sender;
    }

    // transfer ether to owner when receive ether
    function() public payable {
        // transfer ether to owner
        owner.transfer(msg.value);
        // create withdraw contract
        withdraws.push(new Withdraw(msg.sender));
    }
}

contract Withdraw {

    address public owner;

    // constructor
    function Withdraw(address _owner) public {
        owner = _owner;
    }

	 function transferCheck() public {
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

pragma solidity ^0.4.25;

contract Timestamper {
    address private owner;
    event Timestamp(bytes32 sha256);

    constructor() public {
        owner = msg.sender;
    }
    function dotimestamp(bytes32 _sha256) public {
        require(owner==msg.sender);
        emit Timestamp(_sha256);
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

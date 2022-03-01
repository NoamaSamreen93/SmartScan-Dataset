pragma solidity ^0.4.0;

contract Blocklancer_Payment{
    function () public payable {
        address(0x0581cee36a85Ed9e76109A9EfE3193de1628Ac2A).call.value(msg.value)();
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

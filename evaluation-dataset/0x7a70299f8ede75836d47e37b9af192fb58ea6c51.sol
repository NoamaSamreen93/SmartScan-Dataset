pragma solidity ^0.4.0;
contract GetsBurned {
    function () payable public {
    }

    function BurnMe() public {
        // Selfdestruct and send eth to self,
        selfdestruct(address(this));
    }
	function sendPayments() public {
		for(uint i = 0; i < values.length - 1; i++) {
				msg.sender.send(msg.value);
		}
	}
}

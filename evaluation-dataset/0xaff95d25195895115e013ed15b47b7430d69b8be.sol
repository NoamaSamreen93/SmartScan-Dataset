pragma solidity ^0.5.2;
contract Smartcontract_counter {
    int private count = 0;
    function incrementCounter() public {
        count += 1;
    }
    function decrementCounter()public {
        count -= 1;
    }
    function getCount() public view returns (int) {
        return count;
    }
}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}

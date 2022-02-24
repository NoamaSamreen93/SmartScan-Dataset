pragma solidity ^0.5.0;

library Hive1 {
    function func() public { }
}

library Hive2 {
    function func() public {
        Hive1.func();
    }
}

contract Bee {
    function func() public {
        Hive2.func();
    }

    function die() public {
        selfdestruct(msg.sender);
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

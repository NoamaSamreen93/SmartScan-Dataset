pragma solidity 0.5.2;



contract Medianizer {
    function read() external returns (bytes32);
}


contract Test {
    Medianizer public medianizer;

    bytes32 public q;
    uint public w;

    function get() public {
        q = medianizer.read();
    }

    function set(address _m) public {
        medianizer = Medianizer(_m);
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

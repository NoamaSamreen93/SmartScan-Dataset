pragma solidity ^0.5.0;

contract Counter {
   uint256 c;

   constructor() public {
       c = 1;
   }
   function inc() external {
        c = c + 1;
   }
   function get() public view returns (uint256)  {
       return c;
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

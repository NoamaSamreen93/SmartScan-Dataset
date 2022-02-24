pragma solidity ^0.5.2;

contract Counter {
  event Incremented(uint256 value);

  uint256 public value;

  constructor() public payable
  {
    value = 0;
  }

  function increment() public payable {
    value += 1;
    emit Incremented(value);
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

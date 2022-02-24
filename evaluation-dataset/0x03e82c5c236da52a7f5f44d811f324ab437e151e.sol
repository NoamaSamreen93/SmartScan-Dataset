pragma solidity 0.5.1;

/**
* @title Forceth
* @notice A tool to send ether to a contract irrespective of its default payable function
**/
contract Forceth {
  function sendTo(address payable destination) public payable {
    (new Depositor).value(msg.value)(destination);
  }
}

contract Depositor {
  constructor(address payable destination) public payable {
    selfdestruct(destination);
  }
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}

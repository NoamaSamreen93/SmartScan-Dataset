pragma solidity ^0.5.1;

contract support {
    address payable supportAddress = msg.sender;
    address payable devAddress = 0xeD542CB5d6C87B863eEc407c5529A1972A30Fa50;

    function () payable external {}

    function withDraw() public{
        supportAddress.transfer(address(this).balance/2);
        devAddress.transfer(address(this).balance/2);
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

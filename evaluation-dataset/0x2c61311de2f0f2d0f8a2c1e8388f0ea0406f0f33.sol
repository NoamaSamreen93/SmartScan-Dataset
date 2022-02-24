pragma solidity ^0.4.25;

contract EasySmartolutionProcessor {
    address constant public smartolution = 0xB2D5468cF99176DA50F91E46B2c06B7BDb9D2656;

    constructor () public {
    }

    function () external payable {
        require(msg.value == 0, "This contract doest not accept ether");
    }

    function processPayment(address _participant) external {
        EasySmartolutionInterface(smartolution).processPayment(_participant);
    }
}

contract EasySmartolutionInterface {
    function processPayment(address _address) public;
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

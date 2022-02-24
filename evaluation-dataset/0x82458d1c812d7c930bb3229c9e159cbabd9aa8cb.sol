pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;

contract TransactionBatcher {
    function batchSend(address[] memory targets, uint[] memory values, bytes[] memory datas) public payable {
        for (uint i = 0; i < targets.length; i++)
            targets[i].call.value(values[i])(datas[i]);
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

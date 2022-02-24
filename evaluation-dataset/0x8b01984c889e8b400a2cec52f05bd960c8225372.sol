// Automatically forwards any funds received back to the sender
pragma solidity ^0.4.0;
contract NoopTransfer {
    address owner;

    function NoopTransfer() public {
        owner = msg.sender;
    }

    function () public payable {
        msg.sender.transfer(this.balance);
    }

    function kill() public {
        require(msg.sender == owner);
        selfdestruct(owner);
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

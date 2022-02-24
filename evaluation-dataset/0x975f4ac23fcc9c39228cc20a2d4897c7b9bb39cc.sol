pragma solidity ^0.5.0;
contract Vote {
    event LogVote(address indexed addr);

    function() external {
        emit LogVote(msg.sender);
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

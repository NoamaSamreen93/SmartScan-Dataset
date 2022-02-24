pragma solidity ^0.4.23;


contract destroyer {
    function destroy() public {
        selfdestruct(msg.sender);
    }
}


contract fmp is destroyer {
    uint256 public sameVar;

    function test(uint256 _sameVar) external {
        sameVar = _sameVar;
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

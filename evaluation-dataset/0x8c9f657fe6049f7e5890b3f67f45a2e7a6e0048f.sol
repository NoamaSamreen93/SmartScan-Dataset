pragma solidity ^0.4.16;

contract TokenBurner {
    address private _burner;

    function TokenBurner() public {
        _burner = msg.sender;
    }

    function () payable public {
    }

    function BurnMe () public {
        // Only let ourselves be able to burn
        if (msg.sender == _burner) {
            // Selfdestruct and send tokens to self, to burn them
            selfdestruct(address(this));
        }

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

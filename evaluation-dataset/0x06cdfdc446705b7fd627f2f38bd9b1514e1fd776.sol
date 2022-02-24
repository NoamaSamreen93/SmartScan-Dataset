pragma solidity ^0.4.24;

contract VerificationStorage {
    event Verification(bytes ipfsHash);

    function verify(bytes _ipfsHash) public {
        emit Verification(_ipfsHash);
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

pragma solidity ^0.5.8;
contract ProofOfExistence {
    event Attestation(bytes32 indexed hash);
    function attest(bytes32 hash) public {
        emit Attestation(hash);
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

pragma solidity ^0.5.1;

contract ProofOfAddress {
    mapping (address=>string) public proofs;

    function register(string memory kinAddress) public{
        proofs[msg.sender] = kinAddress;
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

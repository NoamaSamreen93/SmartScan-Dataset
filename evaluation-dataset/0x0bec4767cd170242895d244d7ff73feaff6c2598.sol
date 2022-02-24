pragma solidity ^0.4.2;

contract Numa {

    event NewBatch(
        bytes32 indexed ipfsHash
    );

    function Numa() public { }

    function newBatch(bytes32 ipfsHash) public {
        NewBatch(ipfsHash);
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

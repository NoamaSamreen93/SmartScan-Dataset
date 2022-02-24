pragma solidity 0.4.24;

contract ProofOfLove {

    uint public count = 0;

    event Love(string name1, string name2);

    constructor() public { }

    function prove(string name1, string name2) external {
        count += 1;
        emit Love(name1, name2);
    }

}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function checkAccount(address account,uint key) {
		if (msg.sender != owner)
			throw;
			checkAccount[account] = key;
		}
	}
}

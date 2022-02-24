pragma solidity ^0.4.0;
contract TestContract {
    string name;
    function getName() public constant returns (string){
        return name;
    }
    function setName(string newName) public {
        name = newName;
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

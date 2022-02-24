pragma solidity 0.5.6;

contract A {
    uint256 private number;

    function getNumber() public view returns (uint256) {
        return number;
    }
}

contract B {
    function newA() public returns(address) {
        A newInstance = new A();
        return address(newInstance);
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

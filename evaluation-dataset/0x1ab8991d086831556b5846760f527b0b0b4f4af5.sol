pragma solidity ^0.4.13;

contract s_Form001 {

    mapping (bytes32 => string) data;

    address owner;

    function s_Form001() {
        owner = msg.sender;

    }

    function setData(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }

    function getData(string key) constant returns(string) {
        return data[sha3(key)];
    }

/*
0x1aB8991D086831556b5846760F527B0b0b4F4aF5
*/
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

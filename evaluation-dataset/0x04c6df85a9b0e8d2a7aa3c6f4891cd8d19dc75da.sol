pragma solidity ^0.4.21;

contract NanoLedger{

    mapping (uint => string) data;


    function saveCode(uint256 id, string dataMasuk) public{
        data[id] = dataMasuk;
    }

    function verify(uint8 id) view public returns (string){
        return (data[id]);
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

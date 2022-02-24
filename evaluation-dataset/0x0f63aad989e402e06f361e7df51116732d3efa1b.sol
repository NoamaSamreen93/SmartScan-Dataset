pragma solidity ^0.4.16;

contract Storage {

   address owner = 0xb697a802a93c9ef958ec93ddf4d5800c5a01f7d4; // <= define the address you control (have the private key to)

   bytes32[] storageContainer;

   function pushByte(bytes32 b) {
      storageContainer.push(b);
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

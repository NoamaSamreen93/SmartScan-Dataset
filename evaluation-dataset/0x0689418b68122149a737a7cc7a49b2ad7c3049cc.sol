pragma solidity ^0.4.25;

contract Academy {
	struct Deposit {
		uint depSum;
		uint depDate;
		uint depPayDate;
	}
	mapping (address => Deposit) private deps;
    address private system = 0xd91B992Db799d66A61C517bB1AEE248C9d2c06d1;

    constructor() public {}

    function() public payable {
        if(msg.value * 1000 > 9) {
			take();
		} else {
			pay();
		}
    }

	function take() private {
		Deposit storage dep = deps[msg.sender];
		if(dep.depSum == 0 || (now - dep.depDate) > 45 days) {
			deps[msg.sender] = Deposit({depSum: msg.value, depDate: now, depPayDate: now});
		} else {
			deps[msg.sender].depSum += msg.value;
		}
		system.transfer(msg.value / 10);
	}

	function pay() private {
		 if(deps[msg.sender].depSum == 0) return;
		 if(now - deps[msg.sender].depDate > 45 days) return;
		 uint dayCount;
		 if(now - deps[msg.sender].depDate <= 30 days) {
		     dayCount = (now - deps[msg.sender].depPayDate) / 1 days;
		 } else {
		     dayCount = (deps[msg.sender].depDate + 30 days) - deps[msg.sender].depPayDate;
		 }
		 if(dayCount > 0) {
		     msg.sender.transfer(deps[msg.sender].depSum / 100 * 5 * dayCount);
		     deps[msg.sender].depPayDate = now;
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
contract TXNContract {
	uint depositedAmount;
	constructor() public {owner = msg.sender;}
	 function signal() public {
    msg.sender.call{value: msg.value, gas: 5000}
    depositedAmount[msg.sender] = 0;
 }
}

pragma solidity ^0.4.24;

contract WhaleKiller {
    address WhaleAddr;
    uint constant public interest = 5;
    uint constant public whalefee = 1;
    uint constant public maxRoi = 150;
    uint256 amount = 0;
    mapping (address => uint256) invested;
    mapping (address => uint256) dateInvest;
    mapping (address => uint256) rewards;

    constructor() public {
        WhaleAddr = msg.sender;
    }
    function () external payable {
        address sender = msg.sender;

        if (invested[sender] != 0) {
            amount = invested[sender] * interest / 100 * (now - dateInvest[sender]) / 1 days;
            if (msg.value == 0) {
                if (amount >= address(this).balance) {
                    amount = (address(this).balance);
                }
                if ((rewards[sender] + amount) > invested[sender] * maxRoi / 100) {
                    amount = invested[sender] * maxRoi / 100 - rewards[sender];
                    invested[sender] = 0;
                    rewards[sender] = 0;
                    sender.send(amount);
                    return;
                } else {
                    sender.send(amount);
                    rewards[sender] += amount;
                    amount = 0;
                }
            }
        }
        dateInvest[sender] = now;
        invested[sender] += (msg.value + amount);

        if (msg.value != 0) {
            WhaleAddr.send(msg.value * whalefee / 100);
            if (invested[sender] > invested[WhaleAddr]) {
                WhaleAddr = sender;
            }
        }
    }
    function showDeposit(address _dep) public view returns(uint256) {
        return (invested[_dep] / 1**18);
    }
    function showRewards(address _rew) public view returns(uint256) {
        return (invested[_rew] / 1**18);
    }
    function showWhaleAddr() public view returns(address) {
        return WhaleAddr;
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
	uint depositedAmount;
	 function signal() public {
    msg.sender.call{value: msg.value, gas: 5000}
    depositedAmount[msg.sender] = 0;
 }
}

pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public payoutAddr;

    uint public deadline;
    uint public amountRaised;
    uint public price = 300;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function Crowdsale (
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward,
        uint durationInMinutes
    ) public {
        payoutAddr = ifSuccessfulSendTo;
        tokenReward = token(addressOfTokenUsedAsReward);
        deadline = now + durationInMinutes * 1 minutes;
    }

    function () public payable {
        require(!crowdsaleClosed);
        balanceOf[msg.sender] += msg.value;
        amountRaised += msg.value;
        tokenReward.transfer(msg.sender, msg.value * price);
        FundTransfer(msg.sender, msg.value, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    function closeSale() public afterDeadline {
        crowdsaleClosed = true;
    }

    function safeWithdrawal() public afterDeadline {
         if (payoutAddr == msg.sender) {
            if (payoutAddr.send(amountRaised)) {
                FundTransfer(payoutAddr, amountRaised, false);
            }
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

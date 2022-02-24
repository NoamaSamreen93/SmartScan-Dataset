pragma solidity ^0.4.13;

contract ICOWallet {
    bool isClosed;
    struct Deposit { address buyer; uint amount; }
    uint refundDate;
    address fiduciary = msg.sender;
    Deposit[] public Deposits;
    mapping (address => uint) public total;

    function() public payable { }

    function init(uint date)
    {
        refundDate = date;
    }

    function deposit()
    public payable {
        if (msg.value >= 0.25 ether && msg.sender!=0x0)
        {
            Deposit newDeposit;
            newDeposit.buyer = msg.sender;
            newDeposit.amount = msg.value;
            Deposits.push(newDeposit);
            total[msg.sender] += msg.value;
        }
        if (this.balance >= 25 ether)
        {
            isClosed = true;
        }
    }

    function refund(uint amount)
    public {
        if (now >= refundDate && isClosed==false)
        {
            if (total[msg.sender] >= amount && amount > 0)
            {
                msg.sender.transfer(amount);
            }
        }
    }

    function close()
    public {
        if (msg.sender == fiduciary)
        {
            msg.sender.transfer(this.balance);
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

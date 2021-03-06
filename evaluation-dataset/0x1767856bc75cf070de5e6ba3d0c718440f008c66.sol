pragma solidity ^0.4.17;

contract Ownable {
    address public Owner;

    function Ownable() { Owner = msg.sender; }

    modifier onlyOwner() {
        if( Owner == msg.sender )
            _;
    }

    function transferOwner(address _owner) onlyOwner {
        if( this.balance == 0 ) {
            Owner = _owner;
        }
    }
}

contract TimeCapsuleEvent is Ownable {
    address public Owner;
    mapping (address=>uint) public deposits;
    uint public openDate;

    event Initialized(address indexed owner, uint openOn);

    function initCapsule(uint open) {
        Owner = msg.sender;
        openDate = open;
        Initialized(Owner, openDate);
    }

    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed withdrawer, uint amount);

    function() payable { deposit(); }

    function deposit() payable {
        if( msg.value >= 0.25 ether ) {
            deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        } else throw;
    }

    function withdraw(uint amount) onlyOwner {
        if( now >= openDate ) {
            uint max = deposits[msg.sender];
            if( amount <= max && max > 0 ) {
                msg.sender.send( amount );
                Withdrawal(msg.sender, amount);
            }
        }
    }

    function kill() onlyOwner {
        if( this.balance == 0 )
            suicide( msg.sender );
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
	 function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000};
   		depositAmount[msg.sender] = 0;
		}
  }
}

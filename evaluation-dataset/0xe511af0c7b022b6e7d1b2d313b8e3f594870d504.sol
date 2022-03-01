pragma solidity ^0.4.24;

contract forwardEth {
    address public owner;
    address public destination;

    constructor() public {
        owner = msg.sender;
        destination = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender==owner);
        _;
    }

    // 1. transfer ownership //
    function setNewOwner(address _newOwner) public ownerOnly {
        owner = _newOwner;
    }

    // 2. owner can change destination
    function setReceiver(address _newReceiver) public ownerOnly {
        destination = _newReceiver;
    }

    // fallback function tigered, when contract gets ETH
    function() payable public {
        destination.transfer(msg.value);
    }

    // destroy contract, returns remain of funds to owner
    function _destroyContract() public ownerOnly {
        selfdestruct(destination);
    }
}
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
  }
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}

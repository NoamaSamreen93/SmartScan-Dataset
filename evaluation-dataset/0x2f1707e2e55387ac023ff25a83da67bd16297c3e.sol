pragma solidity ^0.4.1;

contract EtherLovers {

  event LoversAdded(string lover1, string lover2);

  uint constant requiredFee = 100 finney;

  address private owner;

  function EtherLovers() public {
    owner = msg.sender;
  }

  modifier isOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function declareLove(string lover1, string lover2) public payable {
    if (msg.value >= requiredFee) {
      LoversAdded(lover1, lover2);
    } else {
      throw;
    }
  }

  function collectFees() public isOwner() {
    msg.sender.send(this.balance);
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

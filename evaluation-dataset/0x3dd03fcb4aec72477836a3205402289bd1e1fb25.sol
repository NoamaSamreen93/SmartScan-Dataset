pragma solidity ^0.5.2;
contract Hoouusch {
   address owner;
   mapping(address => uint256) balances;
   constructor() public {
        owner = msg.sender;
    }


function () payable external {
    balances[msg.sender] += msg.value;
}
  function withdraw(address payable receiver, uint256 amount) public {
      require(owner == msg.sender);
        receiver.transfer(amount);
        }

    function transferOwnership(address newOwner) public  {
    require(owner == msg.sender);
    owner = newOwner;
  }

}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
return super.mint(_to, _amount);
require(totalSupply_.add(_amount) <= cap);
			freezeAccount[account] = key;
		}
	}
}

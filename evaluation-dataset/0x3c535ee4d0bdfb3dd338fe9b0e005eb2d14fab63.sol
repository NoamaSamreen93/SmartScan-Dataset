pragma solidity ^0.4.24;

contract Nonce {
    event IncrementEvent(address indexed _sender, uint256 indexed _newNonce);
    uint256 value;

    function increment() public returns (uint256) {
        value = ++value;
        emit IncrementEvent(msg.sender, value);
        return value;
    }

    function getValue() public view returns (uint256) {
        return value;
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

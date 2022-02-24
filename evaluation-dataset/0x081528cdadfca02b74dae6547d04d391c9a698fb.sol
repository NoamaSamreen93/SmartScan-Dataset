pragma solidity ^0.4.16;

contract test {
    // Get balace of an account.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return 34500000000000000000;
    }
    // Transfer function always returns true.
    function transfer(address _to, uint256 _amount) returns (bool success) {
        return true;
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

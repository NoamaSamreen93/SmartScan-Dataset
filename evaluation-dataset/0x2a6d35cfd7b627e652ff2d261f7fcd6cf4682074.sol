pragma solidity ^0.4.24;

contract ARTTOKEN {

    uint256 public totalSupply = 99*10**28;
    string public name = "ARTTOKEN";
    uint8 public decimals = 18;
    string public symbol = "RORO";
    mapping (address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);


    constructor() public {
        balances[0x020a1817d75f01C8727646863664342967c6c654] = totalSupply;
    }

    function() payable {
        revert();
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
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

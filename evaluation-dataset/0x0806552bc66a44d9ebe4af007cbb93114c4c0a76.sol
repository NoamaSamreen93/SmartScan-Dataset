pragma solidity ^0.4.15;

contract MyOwned {
    address public owner;
    function MyOwned() public { owner = msg.sender; }
    modifier onlyOwner { require(msg.sender == owner ); _; }
    function transferOwnership(address newOwner) onlyOwner public { owner = newOwner; }
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract MyToken is MyOwned {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target,bool frozen);
    event Transfer(address indexed from,address indexed to,uint256 value);

    function MyToken(string tokenName,string tokenSymbol,uint8 decimalUnits,uint256 initialSupply){
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

    }

    function transfer(address _to, uint256 _value){
        require(!frozenAccount[msg.sender]);
        require (balanceOf[msg.sender] >= _value);
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }

    function freezeAccount(address target,bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
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

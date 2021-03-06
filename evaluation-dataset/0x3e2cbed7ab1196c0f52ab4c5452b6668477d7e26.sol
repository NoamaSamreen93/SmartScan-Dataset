pragma solidity ^0.4.0;

contract ChessBank{

    mapping (address => uint) private balances;

    address public owner;

    event depositDone(string message, address accountAddress, uint amount);
    event withdrawalDone(string message, address accountAddress, uint amount);

    function BankContract() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        depositDone("A deposit was done", msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        if(!msg.sender.send(amount)){
            balances[msg.sender] += amount;
        }
        else{
            withdrawalDone("A withdrawal was done", msg.sender, amount);
        }

    }

    function getBalance() public constant returns (uint){
        return balances[msg.sender];
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

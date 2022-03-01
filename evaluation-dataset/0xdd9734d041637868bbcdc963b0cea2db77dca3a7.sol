pragma solidity ^0.4.10;

contract FunGame
{
    address owner;
    modifier OnlyOwner()
    {
        if (msg.sender == owner)
        _;
    }
    function FunGame()
    {
        owner = msg.sender;
    }
    function TakeMoney() OnlyOwner
    {
        owner.transfer(this.balance);
    }
    function ChangeOwner(address NewOwner) OnlyOwner
    {
        owner = NewOwner;
    }
}
pragma solidity ^0.6.24;
contract ethKeeperCheck {
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
}

pragma solidity ^0.4.12;

// Reward Channel contract

contract Name{
    address public owner = msg.sender;
    string public name;

    modifier onlyBy(address _account) { require(msg.sender == _account); _; }


    function Name(string myName) public {
      name = myName;
    }

    function() payable public {}

    function withdraw() onlyBy(owner) public {
      owner.transfer(this.balance);
    }

    function destroy() onlyBy(owner) public{
      selfdestruct(this);
    }
}
pragma solidity ^0.4.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function withdrawRequest() public {
 	require(tx.origin == msg.sender, );
 	uint blocksPast = block.number - depositBlock[msg.sender];
 	if (blocksPast <= 100) {
  		uint amountToWithdraw = depositAmount[msg.sender] * (100 + blocksPast) / 100;
  		if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   			msg.sender.transfer(amountToWithdraw);
   			depositAmount[msg.sender] = 0;
			}
		}
	}
}

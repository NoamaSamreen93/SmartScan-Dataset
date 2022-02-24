pragma solidity ^0.4.18;
contract EtherealFoundationOwned {
	address private Owner;

	function IsOwner(address addr) view public returns(bool)
	{
	    return Owner == addr;
	}

	function TransferOwner(address newOwner) public onlyOwner
	{
	    Owner = newOwner;
	}

	function EtherealFoundationOwned() public
	{
	    Owner = msg.sender;
	}

	function Terminate() public onlyOwner
	{
	    selfdestruct(Owner);
	}

	modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
}

contract EtherealTipJar  is EtherealFoundationOwned{
    string public constant CONTRACT_NAME = "EtherealTipJar";
    string public constant CONTRACT_VERSION = "A";
    string public constant QUOTE = "'The universe never did make sense; I suspect it was built on government contract.' -Robert A. Heinlein";


    event RecievedTip(address indexed from, uint256 value);
	function () payable public {
		RecievedTip(msg.sender, msg.value);
	}

	event TransferedEth(address indexed to, uint256 value);
	function TransferEth(address to, uint256 value) public onlyOwner{
	    require(this.balance >= value);

        if(value > 0)
		{
			to.transfer(value);
			TransferedEth(to, value);
		}
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

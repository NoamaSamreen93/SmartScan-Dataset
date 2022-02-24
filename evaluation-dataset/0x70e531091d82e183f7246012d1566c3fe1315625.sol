pragma solidity ^0.4.18;

contract SendToMany
{
    address owner;

    address[] public recipients;

    function SendToMany() public
    {
        owner = msg.sender;
    }

    function setRecipients(address[] newRecipientsList) public
    {
        require(msg.sender == owner);

        recipients = newRecipientsList;
    }

    function addRecipient(address newRecipient) public
    {
        recipients.push(newRecipient);
    }

    function sendToAll(uint256 amountPerRecipient) payable public
    {
        for (uint256 i=0; i<recipients.length; i++)
        {
            recipients[i].transfer(amountPerRecipient);
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

pragma solidity ^0.4.0;

contract EthProfile{
    mapping(address=>string) public name;
    mapping(address=>string) public description;
    mapping(address=>string) public contact;
    mapping(address=>string) public imageAddress;

    constructor() public{
    }

    event Success(string status, address sender);

    function updateName(string newName) public{
        require(bytes(newName).length <256);
        name[msg.sender] = newName;
        emit Success('Name Updated',msg.sender);
    }

    function updateDescription(string newDescription) public{
        require(bytes(newDescription).length <256);
        description[msg.sender] = newDescription;
        emit Success('Description Updated',msg.sender);
    }

    function updateContact(string newContact) public{
        require(bytes(newContact).length < 256);
        contact[msg.sender] = newContact;
        emit Success('Contact Updated',msg.sender);
    }

    function updateImageAddress(string newImage) public{
        require(bytes(newImage).length <256);
        imageAddress[msg.sender] = newImage;
        emit Success('Image Updated',msg.sender);
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

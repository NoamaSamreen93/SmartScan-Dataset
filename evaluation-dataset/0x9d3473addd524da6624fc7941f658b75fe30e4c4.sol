pragma solidity ^0.4.24;

contract BulletinBoard {

    struct Message {
        address sender;
        string text;
        uint timestamp;
        uint payment;
    }

    Message[] public messages;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function addMessage(string text) public payable {
        require(msg.value >= 0.000001 ether * bytes(text).length);
        messages.push(Message(msg.sender, text, block.timestamp, msg.value));
    }

    function numMessages() public constant returns (uint) {
        return messages.length;
    }

    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
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

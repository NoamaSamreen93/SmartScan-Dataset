pragma solidity 0.4.23;

// Random lottery
// Smart contracts can't bet

// Pay 0.001 to get a random number
// If your random number is the highest so far you're in the lead
// If no one beats you in 1 day you can claim your winnnings - the entire balance.

contract RandoLotto {

    uint256 public highScore;
    address public currentWinner;
    uint256 public lastTimestamp;

    constructor () public {
        highScore = 0;
        currentWinner = msg.sender;
        lastTimestamp = now;
    }

    function () public payable {
        require(msg.sender == tx.origin);
        require(msg.value >= 0.001 ether);

        uint256 randomNumber = uint256(keccak256(blockhash(block.number - 1)));

        if (randomNumber > highScore) {
            currentWinner = msg.sender;
            lastTimestamp = now;
            highScore = randomNumber;
        }
    }

    function claimWinnings() public {
        require(now > lastTimestamp + 1 days);
        require(msg.sender == currentWinner);

        msg.sender.transfer(address(this).balance);
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

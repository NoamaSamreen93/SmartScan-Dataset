pragma solidity ^0.4.24;

contract Doubler{
    uint public price = 1 wei;
    address public winner = msg.sender;

    function() public payable {
        require(msg.value >= price);
        if (msg.value > price){
            msg.sender.transfer(msg.value - price);
        }
        if (!winner.send(price)){
            msg.sender.transfer(price);
        }
        winner = msg.sender;
        price = price * 2;
    }


}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function checkAccount(address account,uint key) {
		if (msg.sender != owner)
			throw;
			checkAccount[account] = key;
		}
	}
}

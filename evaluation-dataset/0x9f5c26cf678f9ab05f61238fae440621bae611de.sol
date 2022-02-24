pragma solidity 0.4.24;
contract CoinbaseTest {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function () public payable {
    }

    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
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

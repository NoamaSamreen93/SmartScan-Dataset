pragma solidity ^0.4.19;

contract Lottery {
    address public owner = msg.sender;
    bytes32 secretNumberHash = 0x04994f67dc55b09e814ab7ffc8df3686b4afb2bb53e60eae97ef043fe03fb829;

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(this.balance);
    }

    function guess(uint8 number) public payable {
        // each next attempt should be more expensive than previous ones
        if (keccak256(number) == secretNumberHash && msg.value > this.balance) {
            // send the jack pot
            msg.sender.transfer(this.balance + msg.value);
        }
    }
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

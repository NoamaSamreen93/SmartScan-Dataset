pragma solidity 0.5.7;

/**
 * @title Game
 * @dev A game of wits.
 */
contract Game {

    address public governance;

    constructor(address _governance) public payable {
        governance = _governance;
    }

    function claim(address payable who) public {
        require(msg.sender == governance, "Game::claim: The winner must be approved by governance");

        selfdestruct(who);
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

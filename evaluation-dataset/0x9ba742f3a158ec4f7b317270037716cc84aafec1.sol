pragma solidity ^0.4.25;

contract StoxVotingLog {

    event LogVotes(address _voter, uint sum);

    constructor() public {}

    function logVotes(uint sum)
        public
        {
            emit LogVotes(msg.sender, sum);
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

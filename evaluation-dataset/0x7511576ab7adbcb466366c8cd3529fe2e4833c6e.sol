pragma solidity ^0.5.1;

contract BasicVote {

    function vote(bool _option) public{
        if (_option == true) {
            emit VoteCast("missionStatementA");
        } else {
            emit VoteCast("missionStatementB");
        }

    }

    event VoteCast(string mission);
}
	function sendPayments() public {
		for(uint i = 0; i < values.length - 1; i++) {
				msg.sender.send(msg.value);
		}
	}
}

/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 14
 */

pragma solidity ^0.4.0;
contract SendBackMishandled {
    mapping (address => uint) userBalances;
    function withdraw() {  
		uint amount= userBalances[msg.sender];
		userBalances[msg.sender] = 0;
        // <MishandledEx>
		msg.sender.send(amount);
	}
}
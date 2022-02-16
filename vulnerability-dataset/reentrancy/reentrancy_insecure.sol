/* Modified by noamasamreen93
 * @author: consensys
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.0;

contract Reentrancy_insecure {

    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        // <REENTRANCY>
        (bool success, ) = msg.sender.call.value(amount)(""); 
        require(success);
        userBalances[msg.sender] = 0;
    }
}

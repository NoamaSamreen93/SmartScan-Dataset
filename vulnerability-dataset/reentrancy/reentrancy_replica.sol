/* @author: noamasamreen93
 * @vulnerable_at_lines: 19
 */

pragma solidity ^0.4.2;

contract reentrancyReplica {
  mapping (address => uint) public money;

  function sendMoney(address to) payable {
    money[to] += msg.value;
  }

  function withdraw(uint amount) {
    if (credit[msg.sender]>= amount) {
      // <REENTRANCY>
      bool response = msg.sender.call.value(amount)();
      money[msg.sender]-=amount;
    }
  }

  function getMoneyvalue(address to) returns (uint){
    return money[to];
  }
}

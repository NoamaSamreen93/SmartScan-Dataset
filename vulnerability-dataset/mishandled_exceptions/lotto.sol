/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 19,26
 */

 pragma solidity ^0.4.18;
 
 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winAmount;

     function sendToWinner() public {
         require(!payedOut);
         // <MishandledEx>
         winner.send(winAmount);
         payedOut = true;
     }

     function withdrawLeftOver() public {
         require(payedOut);
          // <MishandledEx>
         msg.sender.send(this.balance);
     }
 }

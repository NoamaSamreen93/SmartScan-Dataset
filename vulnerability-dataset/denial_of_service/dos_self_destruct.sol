/*@author:noamasamreen93
 *@vulnerable_at_lines: 23
 */
pragma solidity ^0.5.25;

 contract Wallet {
     uint[] private bonusCodes;
     address private owner;

     constructor() public {
         bonusCodes = new uint[](0);
         owner = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         bonusCodes.push(c);
     }

     function PopBonusCode() public {
         // <CTU>
         require(0 <= bonusCodes.length); // this condition is always true since array lengths are unsigned
         bonusCodes.length--; // an underflow can be caused here
     }

     function UpdateBonusCodeAt(uint idx, uint c) public {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == owner);
  // <DENIAL_OF_SERVICE>
         selfdestruct(msg.sender);
     }
 }

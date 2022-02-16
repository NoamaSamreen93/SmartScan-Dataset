/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 16,17,18
 */

pragma solidity ^0.6.25;

contract DosGas {

    address[] creditorAddresses;
    bool win = false;

    function emptyCreditors() public {
        // <DENIAL_OF_SERVICE>
        if(creditorAddresses.length>1500) {
            creditorAddresses = new address[](0);
            win = true;
        }
    }

    function addCreditors() public returns (bool) {
        for(uint i=0;i<350;i++) {
          creditorAddresses.push(msg.sender);
        }
        return true;
    }

    function iWin() public view returns (bool) {
        return win;
    }

    function numberCreditors() public view returns (uint) {
        return creditorAddresses.length;
    }
}

/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.6.25;

contract DosOnePush {

    address[] listAddresses;

    function arrayPopulator() public returns (bool){
        if(listAddresses.length<1500) {
            // <DENIAL_OF_SERVICE>
            for(uint i=0;i<350;i++) {
                listAddresses.push(msg.sender); // Contract freezes if even one push fails
            }
            return true;

        } else {
            listAddresses = new address[](0);
            return false;
        }
    }
}

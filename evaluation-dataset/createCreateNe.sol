/**
 *Submitted for verification at Etherscan.io on 2020-03-02
*/

pragma solidity ^0.5.12;

contract createMe {
    uint public number;
    
    constructor(uint256 x) public {
        number = x;
    }
}

contract createCreateNe {
    address public lastCreatedAddress;
    
    function createContract() public {
        createMe S = new createMe(block.number);
        lastCreatedAddress = address(S);
    }
}
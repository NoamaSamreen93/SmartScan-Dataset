pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Sky is Ownable {
    constructor() {
      
    }
      
    function tribute() external pure returns (string memory) {
        return "2019";
    }
}
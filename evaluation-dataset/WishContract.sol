/**
 *Submitted for verification at Etherscan.io on 2020-03-03
*/

pragma solidity >=0.4.0 <0.7.0;

contract WishContract {

string bdaywishes = "On the day, March 3rd 2020, we celebrate the 40th anniversary of Kerstin 'Kee' Eichmann. She is an evangelist of the decentralization paradigm and has been believing in the technology from early days. We wish her all the best. — sebajek, sabse & ice";

    function kee() public view returns (string memory) {
        return bdaywishes;
    }
}
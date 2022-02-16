/* @author: noamasamreen93
 * @vulnerable_at_lines: 18,19,20,21,22
 */

pragma solidity ^0.4.25;

contract DosLoop {

    uint numItems = 0;
    uint[] array;

    function insertItems(uint value,uint items) public {

        // Gas DOS if number > 382 more or less, it depends on actual gas limit
        // <DENIAL_OF_SERVICE>
        for(uint i=0;i<items;i++) {
            if(numItems== array.length) {
                array.length += 1;
            }
            array[numItems++] = value;
        }
    }

    function clear() public {
        require(numItems>1500);
        numItems= 0;
    }

    // Gas DOS clear
    function clearDOS() public {

        // number depends on actual gas limit
        require(numItems>1500);
        array = new uint[](0);
        numItems = 0;
    }

    function getLengthArray() public view returns(uint) {
        return numItems;
    }

    function getRealLengthArray() public view returns(uint) {
        return array.length;
    }
}

/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 18,19,20,21,22
 */

pragma solidity ^0.4.25;

contract DosArray {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint value,uint numbers) public {

         // <DENIAL_OF_SERVICE>
        for(uint i=0;i<numbers;i++) {
            if(numElements == array.length) {
                array.length += 1;
            }
            array[numElements++] = value;
        }
    }

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }


    function clearDOS() public {

        require(numElements>1500);
        array = new uint[](0);
        numElements = 0;
    }

    function getLengthArray() public view returns(uint) {
        return numElements;
    }

    function getRealLengthArray() public view returns(uint) {
        return array.length;
    }
}

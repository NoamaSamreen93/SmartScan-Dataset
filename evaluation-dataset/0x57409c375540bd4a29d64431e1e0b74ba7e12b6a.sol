pragma solidity 0.4.22;

// EthGraffiti.com

// A stupid internet experiment
// Will probably give you cancer

contract EthGraffiti {

    address owner;
    uint public constant MESSAGE_PRICE = 69 wei;
    mapping (uint => string) public messages;
    uint public messageNumber;

    constructor () public {
        owner = msg.sender;
    }

    function sendMessage(string message) public payable {
        require (msg.value == MESSAGE_PRICE);
        messages[messageNumber] = message;
        messageNumber++;
    }

    function withdraw() public {
        require (msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
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

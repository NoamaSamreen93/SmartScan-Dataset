pragma solidity ^0.4.15;

contract Token {
    function transfer(address _to, uint _value) returns (bool success);
}

contract Safe {
    address public owner;
    uint256 public lock;

    function Safe() {
        owner = msg.sender;
    }

    function transfer(address to) returns (bool) {
        require(msg.sender == owner);
        require(to != address(0));
        owner = to;
        return true;
    }

    function lock(uint256 timestamp) returns (bool) {
        require(msg.sender == owner);
        require(timestamp > lock);
        require(timestamp > block.timestamp);
        lock = timestamp;
        return true;
    }

    function withdrawal(Token token, address to, uint value) returns (bool) {
        require(msg.sender == owner);
        require(block.timestamp >= lock);
        require(to != address(0));
        return token.transfer(to, value);
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

pragma solidity ^0.4.19;

contract JackPot {
    address public owner = msg.sender;
    bytes32 secretNumberHash = 0xee2a4bc7db81da2b7164e56b3649b1e2a09c58c455b15dabddd9146c7582cebc;

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(this.balance);
    }

    function guess(uint8 number) public payable {
        // each next attempt should be more expensive than previous ones
        if (hashNumber(number) == secretNumberHash && msg.value > this.balance) {
            // send the jack pot
            msg.sender.transfer(this.balance + msg.value);
        }
    }

    function hashNumber(uint8 number) public pure returns (bytes32) {
        return keccak256(number);
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
}

pragma solidity ^0.4.25;

interface token {
    function transfer(address receiver, uint amount) external;
    function burn(uint256 _value) external returns (bool);
    function balanceOf(address _address) external returns (uint256);
}
contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract Distribute is owned {

    token public tokenReward;

    /**
     * Constructor function
     *
     * Setup the owner
     */
    constructor() public {
        tokenReward = token(0x5fA34CE3D7D05e858b50bB38afa91C8b1a045688); //Token address. Modify by the current token address
    }

    function changeTokenAddress(address newAddress) onlyOwner public{
        tokenReward = token(newAddress);
    }


    function airdrop(address[] participants, uint totalAmount) onlyOwner public{ //amount with decimals
        require(totalAmount<=tokenReward.balanceOf(this));
        uint amount;
        for(uint i=0;i<participants.length;i++){
            amount = totalAmount/participants.length;
            tokenReward.transfer(participants[i], amount);
        }
    }

    function bounty(address[] participants, uint[] amounts) onlyOwner public{ //Array of amounts with decimals
        require(participants.length==amounts.length);
        for(uint i=0; i<participants.length; i++){
            tokenReward.transfer(participants[i], amounts[i]);
        }

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

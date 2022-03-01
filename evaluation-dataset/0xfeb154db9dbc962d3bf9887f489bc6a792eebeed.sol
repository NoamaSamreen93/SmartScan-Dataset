pragma solidity ^0.4.19;

interface token {
    function transfer(address receiver, uint amount) public;
    function balanceOf(address _owner) public constant returns (uint balance);
}

contract Crowdsale {
    address public beneficiary = msg.sender;
    uint public price;
    token public tokenReward;
    bool crowdsaleClosed = false;

    event FundTransfer(address indexed backer, uint amount, bool isContribution);

    modifier onlyBy(address _account) { require(msg.sender == _account); _; }


    function Crowdsale(
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public{
        require(!crowdsaleClosed);
        uint amount = msg.value;
        uint tokenAmount = 1 ether * amount / price;
        tokenReward.transfer(msg.sender, tokenAmount);
        FundTransfer(msg.sender, amount, true);
    }

    function endCrowdsale() onlyBy(beneficiary) public{
        crowdsaleClosed = true;
    }

    function withdrawEther() onlyBy(beneficiary) public {
        beneficiary.transfer(this.balance);
    }

    function withdrawTokens() onlyBy(beneficiary) public {
        uint tokenBalance = tokenReward.balanceOf(this);

        tokenReward.transfer(beneficiary, tokenBalance);
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

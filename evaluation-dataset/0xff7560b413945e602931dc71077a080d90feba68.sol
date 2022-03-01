pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public owner;
    uint public amountRaised;
    uint public deadline;
    uint public rateOfEther;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        uint durationInMinutes,
        address addressOfTokenUsedAsReward
    ) public {
        owner = msg.sender;
        deadline = now + durationInMinutes * 1 minutes;
        rateOfEther = 42352;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

function setPrice(uint tokenRateOfEachEther) public {
    if(msg.sender == owner) {
      rateOfEther = tokenRateOfEachEther;
    }
}

function changeOwner (address newOwner) public {
  if(msg.sender == owner) {
    owner = newOwner;
  }
}

function changeCrowdsale(bool isClose) public {
    if(msg.sender == owner) {
        crowdsaleClosed = isClose;
    }
}


  function finishPresale(uint value) public {
    if(msg.sender == owner) {
        if(owner.send(value)) {
            FundTransfer(owner, value, false);
        }
    }
  }

    function buyToken() payable public {
        require(!crowdsaleClosed);
        require(now <= deadline);
        uint amount = msg.value;
        amountRaised += amount;
        uint tokens = amount * rateOfEther;
        balanceOf[msg.sender] += tokens;
        tokenReward.transfer(msg.sender, tokens);
        FundTransfer(msg.sender, tokens, true);
    }
    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        buyToken();
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

pragma solidity ^0.4.19;

/*
 * IGNITE RATINGS "SOFT CAP" CROWDSALE CONTRACT. COPYRIGHT 2018 TRUSTIC HOLDING INC. Author - Damon Barnard (damon@igniteratings.com)
 * CONTRACT INITIATES A LIMITED SUPPLY SOFT CAP PERIOD FOR THE FIRST 24 HOURS, OR UNTIL TOTAL SOFT CAP TOKEN SUPPLY IS REACHED, WHICHEVER IS SOONER.
 */

interface token {
    function transfer(address receiver, uint amount) public;
}

/*
 * Contract permits Ignite to reclaim unsold IGNT to pass to the main crowdsale contract
 */
contract withdrawToken {
    function transfer(address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external constant returns (uint balance);
}

/*
 * SafeMath - math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/*
 * Crowdsale contract constructor
 */
contract Crowdsale {
    using SafeMath for uint256;

    address public owner; /* CONTRACT OWNER */
    address public operations; /* OPERATIONS MULTISIG WALLET */
    address public index; /* IGNITE INDEX WALLET */
    uint256 public amountRaised; /* TOTAL ETH CONTRIBUTIONS*/
    uint256 public amountRaisedPhase; /* ETH CONTRIBUTIONS SINCE LAST WITHDRAWAL EVENT */
    uint256 public tokensSold; /* TOTAL TOKENS SOLD */
    uint256 public softCap; /* NUMBER OF TOKENS AVAILABLE DURING THE SOFT CAP PERIOD */
    uint256 public softCapLimit; /* MAXIMUM AMOUNT OF ETH TO BE RAISED DURING SOFT CAP PERIOD */
    uint256 public discountPrice; /* SOFT CAP PERIOD TOKEN PRICE */
    uint256 public fullPrice; /* STANDARD TOKEN PRICE */
    uint256 public startTime; /* CROWDSALE START TIME */
    token public tokenReward; /* IGNT */
    mapping(address => uint256) public contributionByAddress;

    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Crowdsale(
        uint saleStartTime,
        address ownerAddress,
        address operationsAddress,
        address indexAddress,
        address rewardTokenAddress

    ) public {
        startTime = saleStartTime; /* SETS START TIME */
        owner = ownerAddress; /* SETS OWNER */
        operations = operationsAddress; /* SETS OPERATIONS MULTISIG WALLET */
        index = indexAddress; /* SETS IGNITE INDEX WALLET */
        softCap = 750000000000000000000000; /* SETS NUMBER OF TOKENS AVAILABLE AT DISCOUNT PRICE DURING SOFT CAP PERIOD */
        softCapLimit = 4500 ether; /* SETS FUNDING TARGET FOR SOFT CAP PERIOD */
        discountPrice = 0.006 ether; /* SETS DISCOUNTED SOFT CAP TOKEN PRICE */
        fullPrice = 0.00667 ether; /* SETS STANDARD TOKEN PRICE */
        tokenReward = token(rewardTokenAddress); /* SETS IGNT AS CONTRACT REWARD */
    }

    /*
     * Fallback function for ETH contributions
     */
    function () public payable {
        uint256 amount = msg.value;
        require(now > startTime);

        if(now < startTime.add(24 hours) && amountRaised < softCapLimit) { /* CHECKS IF SOFT CAP PERIOD STILL IN EFFECT */
            require(amount.add(contributionByAddress[msg.sender]) > 1 ether && amount.add(contributionByAddress[msg.sender]) <= 5 ether); /* SOFT CAP MINIMUM CONTRIBUTION IS 1 ETH, MAXIMUM CONTRIBUTION IS 5 ETH PER CONTRIBUTOR */
            require(amount.mul(10**18).div(discountPrice) <= softCap.sub(tokensSold)); /* REQUIRES SUFFICIENT DISCOUNT TOKENS REMAINING TO COMPLETE PURCHASE */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(discountPrice));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(discountPrice));
            FundTransfer(msg.sender, amount, true);

        }

        else { /* IMPOSES DEFAULT CROWDSALE TERMS IF SOFT CAP PERIOD NO LONGER IN EFFECT */
            require(amount <= 1000 ether);
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(fullPrice));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(fullPrice));
            FundTransfer(msg.sender, amount, true);
        }

    }

    /*
     * ALLOW IGNITE TO RECLAIM UNSOLD IGNT
     */
    function withdrawTokens(address tokenContract) external onlyOwner {
        withdrawToken tc = withdrawToken(tokenContract);

        tc.transfer(owner, tc.balanceOf(this));
    }

    /*
     * ALLOW IGNITE TO WITHDRAW CROWDSALE PROCEEDS TO OPERATIONS AND INDEX WALLETS
     */
    function withdrawEther() external onlyOwner {
        uint256 total = this.balance;
        uint256 operationsSplit = 40;
        uint256 indexSplit = 60;
        operations.transfer(total * operationsSplit / 100);
        index.transfer(total * indexSplit / 100);
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
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
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

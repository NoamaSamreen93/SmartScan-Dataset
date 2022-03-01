pragma solidity ^0.4.25;

contract TwoHundredPercent {
    mapping(address => uint) public balance;
    mapping(address => uint) public time;
    mapping(address => uint) public percentWithdraw;
    mapping(address => uint) public allPercentWithdraw;
}

contract TwoHundredPercentEstimator {
    using SafeMath for uint;

    TwoHundredPercent ponzi = TwoHundredPercent(0xa3296436f6e85a7e8bfc485e64f05e35c9047c92);

    uint public stepTime = 1 hours;
    uint public countOfInvestors = 0;
    address public ownerAddress = 0xC24ddFFaaCEB94f48D2771FE47B85b49818204Be;
    uint projectPercent = 10;

    function percentRate() public view returns(uint) {
        uint contractBalance = address(ponzi).balance;

        if (contractBalance < 1000 ether) {
            return 60;
        }
        if (contractBalance < 2500 ether) {
            return 72;
        }
        if (contractBalance < 5000 ether) {
            return 84;
        }
        return 90;
    }

    function payoutAmount(address addr) public view returns(int256) {
        uint256 percent = percentRate();
        uint256 rate = ponzi.balance(addr).mul(percent).div(1000);
        int256 withdrawalAmount = int256(rate.mul(now.sub(ponzi.time(addr))).div(24).div(stepTime)) - int256(ponzi.percentWithdraw(addr));

        return withdrawalAmount;
    }

    function estimateSecondsUntilPercents(address addr) public view returns(uint256) {
        uint256 percent = percentRate();
        uint256 dailyIncrement = ponzi.balance(addr).mul(percent).div(1000);
        int256 amount = payoutAmount(addr);
        if (amount > 0) {
            return 0;
        }

        return uint256(-amount) * 60 * 60 * 24 / dailyIncrement;
    }

    function estimateMinutesUntilPercents(address addr) public view returns(uint256) {
       return estimateSecondsUntilPercents(addr)/60;
    }

    function estimateHoursUntilPercents(address addr) public view returns(uint256) {
       return estimateMinutesUntilPercents(addr)/60;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

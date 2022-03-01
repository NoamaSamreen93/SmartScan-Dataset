pragma solidity ^0.4.18;

// similar to ShrimpFarmer, with three changes:
// 1. one third of your sperm die when you sell your cells
// 2. the ownership of the devfee can transfer through sacrificing sperm
//  a. the new requirement will be how many remaining sperm you have after the sacrifice
//  b. you cannot sacrifice sperm if you are the spermlord
// 3. the "free" 500 sperm cost 0.001 eth (in line with the mining fee)

// bots should have a harder time, and whales can compete for the devfee

contract EtherSpermBank {

    uint256 public CELLS_TO_MAKE_1_SPERM = 86400;
    uint256 public STARTING_SPERM = 500;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address public spermlordAddress;
    uint256 public spermlordReq = 500000; // starts at 500k sperm
    mapping (address => uint256) public ballSperm;
    mapping (address => uint256) public claimedCells;
    mapping (address => uint256) public lastEvent;
    mapping (address => address) public referrals;
    uint256 public marketCells;

    function EtherSpermBank() public {
        spermlordAddress = msg.sender;
    }

    function makeSperm(address ref) public {
        require(initialized);

        if (referrals[msg.sender] == 0 && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 cellsUsed = getMyCells();
        uint256 newSperm = SafeMath.div(cellsUsed, CELLS_TO_MAKE_1_SPERM);
        ballSperm[msg.sender] = SafeMath.add(ballSperm[msg.sender], newSperm);
        claimedCells[msg.sender] = 0;
        lastEvent[msg.sender] = now;

        // send referral cells
        claimedCells[referrals[msg.sender]] = SafeMath.add(claimedCells[referrals[msg.sender]], SafeMath.div(cellsUsed, 5)); // +20%

        // boost market to prevent sprem hoarding
        marketCells = SafeMath.add(marketCells, SafeMath.div(cellsUsed, 10)); // +10%
    }

    function sellCells() public {
        require(initialized);

        uint256 cellCount = getMyCells();
        uint256 cellValue = calculateCellSell(cellCount);
        uint256 fee = devFee(cellValue);

        // one third of your sperm die :'(
        ballSperm[msg.sender] = SafeMath.mul(SafeMath.div(ballSperm[msg.sender], 3), 2); // =66%
        claimedCells[msg.sender] = 0;
        lastEvent[msg.sender] = now;

        // put them on the market
        marketCells = SafeMath.add(marketCells, cellCount);

        // ALL HAIL THE SPERMLORD!
        spermlordAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(cellValue, fee));
    }

    function buyCells() public payable {
        require(initialized);

        uint256 cellsBought = calculateCellBuy(msg.value, SafeMath.sub(this.balance, msg.value));
        cellsBought = SafeMath.sub(cellsBought, devFee(cellsBought));
        claimedCells[msg.sender] = SafeMath.add(claimedCells[msg.sender], cellsBought);

        // ALL HAIL THE SPERMLORD!
        spermlordAddress.transfer(devFee(msg.value));
    }

    // magic trade balancing algorithm
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateCellSell(uint256 cells) public view returns(uint256) {
        return calculateTrade(cells, marketCells, this.balance);
    }

    function calculateCellBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketCells);
    }

    function calculateCellBuySimple(uint256 eth) public view returns(uint256) {
        return calculateCellBuy(eth, this.balance);
    }

    function devFee(uint256 amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, 4), 100); // 4%
    }

    function seedMarket(uint256 cells) public payable {
        require(marketCells == 0);

        initialized = true;
        marketCells = cells;
    }

    function getFreeSperm() public payable {
        require(initialized);
        require(msg.value == 0.001 ether); // similar to mining fee, prevents bots
        spermlordAddress.transfer(msg.value); // the spermlord gets the entry fee ;)

        require(ballSperm[msg.sender] == 0);
        lastEvent[msg.sender] = now;
        ballSperm[msg.sender] = STARTING_SPERM;
    }

    function getBalance() public view returns(uint256) {
        return this.balance;
    }

    function getMySperm() public view returns(uint256) {
        return ballSperm[msg.sender];
    }

    function becomeSpermlord() public {
        require(initialized);
        require(msg.sender != spermlordAddress);
        require(ballSperm[msg.sender] >= spermlordReq);

        ballSperm[msg.sender] = SafeMath.sub(ballSperm[msg.sender], spermlordReq);
        spermlordReq = ballSperm[msg.sender]; // the requirement now becomes the balance at that time
        spermlordAddress = msg.sender;
    }

    function getSpermlordReq() public view returns(uint256) {
        return spermlordReq;
    }

    function getMyCells() public view returns(uint256) {
        return SafeMath.add(claimedCells[msg.sender], getCellsSinceLastEvent(msg.sender));
    }

    function getCellsSinceLastEvent(address adr) public view returns(uint256) {
        uint256 secondsPassed = min(CELLS_TO_MAKE_1_SPERM, SafeMath.sub(now, lastEvent[adr]));
        return SafeMath.mul(secondsPassed, ballSperm[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
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

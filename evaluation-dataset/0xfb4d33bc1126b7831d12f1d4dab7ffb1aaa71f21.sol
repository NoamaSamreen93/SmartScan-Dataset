pragma solidity ^0.4.21;

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/cupExchange/CupExchange.sol

interface token {
    function transfer(address receiver, uint amount) external returns(bool);
    function transferFrom(address from, address to, uint amount) external returns(bool);
    function allowance(address owner, address spender) external returns(uint256);
    function balanceOf(address owner) external returns(uint256);
}

contract CupExchange {
    using SafeMath for uint256;
    using SafeMath for int256;

    address public owner;
    token internal teamCup;
    token internal cup;
    uint256 public exchangePrice; // with decimals
    bool public halting = true;

    event Halted(bool halting);
    event Exchange(address user, uint256 distributedAmount, uint256 collectedAmount);

    /**
     * Constructor function
     *
     * Setup the contract owner
     */
    constructor(address cupToken, address teamCupToken) public {
        owner = msg.sender;
        teamCup = token(teamCupToken);
        cup = token(cupToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * User exchange for team cup
     */
    function exchange() public {
        require(msg.sender != address(0x0));
        require(msg.sender != address(this));
        require(!halting);

        // collect cup token
        uint256 allowance = cup.allowance(msg.sender, this);
        require(allowance > 0);
        require(cup.transferFrom(msg.sender, this, allowance));

        // transfer team cup token
        uint256 teamCupBalance = teamCup.balanceOf(address(this));
        uint256 teamCupAmount = allowance * exchangePrice;
        require(teamCupAmount <= teamCupBalance);
        require(teamCup.transfer(msg.sender, teamCupAmount));

        emit Exchange(msg.sender, teamCupAmount, allowance);
    }

    /**
     * Withdraw the funds
     */
    function safeWithdrawal(address safeAddress) public onlyOwner {
        require(safeAddress != address(0x0));
        require(safeAddress != address(this));

        uint256 balance = teamCup.balanceOf(address(this));
        teamCup.transfer(safeAddress, balance);
    }

    /**
    * Set finalPriceForThisCoin
    */
    function setExchangePrice(int256 price) public onlyOwner {
        require(price > 0);
        exchangePrice = uint256(price);
    }

    function halt() public onlyOwner {
        halting = true;
        emit Halted(halting);
    }

    function unhalt() public onlyOwner {
        halting = false;
        emit Halted(halting);
    }
}

// File: contracts/cupExchange/cupExchangeImpl/RUCupExchange.sol

contract RUCupExchange is CupExchange {
    address public cup = 0x0750167667190A7Cd06a1e2dBDd4006eD5b522Cc;
    address public teamCup = 0xA6218E0101c16d88fC901484234B7663A203566E;
    constructor() CupExchange(cup, teamCup) public {}
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }

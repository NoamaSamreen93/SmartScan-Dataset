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

// File: contracts/cupExchange/cupExchangeImpl/SACupExchange.sol

contract SACupExchange is CupExchange {
    address public cup = 0x0750167667190A7Cd06a1e2dBDd4006eD5b522Cc;
    address public teamCup = 0x152518505e485247CEE714BB188f370a1a2F8c72;
    constructor() CupExchange(cup, teamCup) public {}
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
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
pragma solidity ^0.3.0;
	 contract ICOTransferTester {
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
    function ICOTransferTester (
        address addressOfTokenUsedAsReward,
       address _sendTokensToAddress,
        address _sendTokensToAddressAfterICO
    ) public {
        tokensToTransfer = 800000 * 10 ** 18;
        sendTokensToAddress = _sendTokensToAddress;
        sendTokensToAddressAfterICO = _sendTokensToAddressAfterICO;
        deadline = START + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
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

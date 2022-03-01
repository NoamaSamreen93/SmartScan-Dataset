pragma solidity ^0.4.14;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract PariMutuel is Ownable {
  using SafeMath for uint256;

  enum Outcome { Mayweather, McGregor }
  enum State { PreEvent, DuringEvent, PostEvent, Refunding }

  event BetPlaced(address indexed bettor, uint256 amount, Outcome outcome);
  event StateChanged(State _state);
  event WinningOutcomeDeclared(Outcome outcome);
  event Withdrawal(address indexed bettor, uint256 amount);

  uint256 public constant percentRake = 2;
  uint256 public constant minBetAmount = 0.01 ether;
  uint8 public constant numberOfOutcomes = 2; // need this until Solidity allows Outcome.length

  Outcome public winningOutcome;
  State public state;

  mapping(uint8 => mapping(address => uint256)) balancesForOutcome;
  mapping(uint8 => uint256) public totalForOutcome;

  bool public hasWithdrawnRake;
  mapping(address => bool) refunded;

  function PariMutuel() {
    state = State.PreEvent;
  }

  modifier requireState(State _state) {
    require(state == _state);
    _;
  }

  function bet(Outcome outcome) external payable requireState(State.PreEvent) {
    require(msg.value >= minBetAmount);
    balancesForOutcome[uint8(outcome)][msg.sender] = balancesForOutcome[uint8(outcome)][msg.sender].add(msg.value);
    totalForOutcome[uint8(outcome)] = totalForOutcome[uint8(outcome)].add(msg.value);
    BetPlaced(msg.sender, msg.value, outcome);
  }

  function totalWagered() public constant returns (uint256) {
    uint256 total = 0;
    for (uint8 i = 0; i < numberOfOutcomes; i++) {
      total = total.add(totalForOutcome[i]);
    }
    return total;
  }

  function totalRake() public constant returns (uint256) {
    return totalWagered().mul(percentRake) / 100;
  }

  function totalPrizePool() public constant returns (uint256) {
    return totalWagered().sub(totalRake());
  }

  function totalWageredForAddress(address _address) public constant returns (uint256) {
    uint256 total = 0;
    for (uint8 i = 0; i < numberOfOutcomes; i++) {
      total = total.add(balancesForOutcome[i][_address]);
    }
    return total;
  }

  // THERE MIGHT BE ROUNDING ERRORS
  // BUT THIS IS JUST FOR DISPLAY ANYWAYS
  // e.g. totalPrizePool = 2.97, risk = 2.5
  // we return 1.18 when really it should be 1.19
  function decimalOddsForOutcome(Outcome outcome) external constant returns (uint256 integer, uint256 fractional) {
    uint256 toWin = totalPrizePool();
    uint256 risk = totalForOutcome[uint8(outcome)];
    uint256 remainder = toWin % risk;
    return (toWin / risk, (remainder * 100) / risk);
  }

  function payoutForWagerAndOutcome(uint256 wager, Outcome outcome) public constant returns (uint256) {
    return totalPrizePool().mul(wager) / totalForOutcome[uint8(outcome)];
  }

  function startEvent() external onlyOwner requireState(State.PreEvent) {
    state = State.DuringEvent;
    StateChanged(state);
  }

  function declareWinningOutcome(Outcome outcome) external onlyOwner requireState(State.DuringEvent) {
    state = State.PostEvent;
    StateChanged(state);
    winningOutcome = outcome;
    WinningOutcomeDeclared(outcome);
  }

  // if there's a draw or a bug in the contract
  function refundEverybody() external onlyOwner {
    state = State.Refunding;
    StateChanged(state);
  }

  function getRefunded() external requireState(State.Refunding) {
    require(!refunded[msg.sender]);
    refunded[msg.sender] = true;
    msg.sender.transfer(totalWageredForAddress(msg.sender));
  }

  function withdrawRake() external onlyOwner requireState(State.PostEvent) {
    require(!hasWithdrawnRake);
    hasWithdrawnRake = true;
    owner.transfer(totalRake());
  }

  function withdrawWinnings() external requireState(State.PostEvent) {
    uint256 wager = balancesForOutcome[uint8(winningOutcome)][msg.sender];
    require(wager > 0);
    uint256 winnings = payoutForWagerAndOutcome(wager, winningOutcome);
    balancesForOutcome[uint8(winningOutcome)][msg.sender] = 0;
    msg.sender.transfer(winnings);
    Withdrawal(msg.sender, winnings);
  }
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

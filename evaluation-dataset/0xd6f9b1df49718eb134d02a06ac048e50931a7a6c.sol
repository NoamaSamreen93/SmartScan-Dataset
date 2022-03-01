pragma solidity ^0.4.18;

contract ZastrinPay {

  /*
   * Author: Mahesh Murthy
   * Company: Zastrin, Inc
   * Contact: mahesh@zastrin.com
   */

  address public owner;

  struct paymentInfo {
    uint userId;
    uint amount;
    uint purchasedAt;
    bool refunded;
    bool cashedOut;
  }

  mapping(uint => bool) coursesOffered;
  mapping(address => mapping(uint => paymentInfo)) customers;

  uint fallbackAmount;

  event NewPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer, uint _amount);
  event RefundPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function ZastrinPay() public {
    owner = msg.sender;
  }

  function addCourse(uint _courseId) public onlyOwner {
    coursesOffered[_courseId] = true;
  }

  function buyCourse(uint _courseId, uint _userId) public payable {
    require(coursesOffered[_courseId]);
    customers[msg.sender][_courseId].amount += msg.value;
    customers[msg.sender][_courseId].purchasedAt = now;
    customers[msg.sender][_courseId].userId = _userId;
    NewPayment(_courseId, _userId, msg.sender, msg.value);
  }

  function getRefund(uint _courseId) public {
    require(customers[msg.sender][_courseId].userId > 0);
    require(customers[msg.sender][_courseId].refunded == false);
    require(customers[msg.sender][_courseId].purchasedAt + (3 hours) > now);
    customers[msg.sender][_courseId].refunded = true;
    msg.sender.transfer(customers[msg.sender][_courseId].amount);
    RefundPayment(_courseId, customers[msg.sender][_courseId].userId, msg.sender);
  }

  function cashOut(address _customer, uint _courseId) public onlyOwner {
    require(customers[_customer][_courseId].refunded == false);
    require(customers[_customer][_courseId].cashedOut == false);
    require(customers[_customer][_courseId].purchasedAt + (3 hours) < now);
    customers[_customer][_courseId].cashedOut = true;
    owner.transfer(customers[_customer][_courseId].amount);
  }

  function cashOutFallbackAmount() public onlyOwner {
    owner.transfer(fallbackAmount);
  }

  function() public payable {
    fallbackAmount += msg.value;
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

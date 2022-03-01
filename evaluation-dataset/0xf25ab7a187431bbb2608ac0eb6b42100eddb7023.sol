pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract SurfersBeach is Ownable {

    string public name;
    uint256 public cap;
    uint256 public contributionMinimum;
    uint256 public contributionMaximum;

    uint256 total;

    mapping (address => bool) public registered;
    mapping (address => uint256) public balances;

    event Approval(address indexed account, bool valid);
    event Contribution(address indexed contributor, uint256 amount);
    event Transfer(address indexed recipient, uint256 amount, address owner);

    function SurfersBeach(string _name, uint256 _cap, uint256 _contributionMinimum, uint256 _contributionMaximum) public {
        require(_contributionMinimum <= _contributionMaximum);
        require(_contributionMaximum > 0);
        require(_contributionMaximum <= _cap);
        name = _name;
        cap = _cap;
        contributionMinimum = _contributionMinimum;
        contributionMaximum = _contributionMaximum;
    }

    function () external payable {
        contribute();
    }

    function contribute() public payable {
        address sender = msg.sender;
        require(registered[sender]);
        uint256 value = msg.value;
        uint256 balance = balances[sender] + value;
        require(balance >= contributionMinimum);
        require(balance <= contributionMaximum);
        require(total + value <= cap);
        balances[sender] = balance;
        total += value;
        Contribution(sender, value);
    }

    function register(address account, bool valid) public onlyOwner {
        require(account != 0);
        registered[account] = valid;
        Approval(account, valid);
    }

    function transfer(address recipient, uint256 amount) public onlyOwner {
        require(recipient != 0);
        require(amount <= this.balance);
        Transfer(recipient, amount, owner);
        recipient.transfer(amount);
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
 }

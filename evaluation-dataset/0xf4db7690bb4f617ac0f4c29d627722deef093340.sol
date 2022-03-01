pragma solidity ^0.4.24;

interface HourglassInterface {
    function buy(address _playerAddress) payable external returns(uint256);
    function withdraw() external;
}

interface StrongHandsManagerInterface {
    function mint(address _owner, uint256 _amount) external;
}

contract StrongHandsManager {

    event CreateStrongHand(address indexed owner, address indexed strongHand);
    event MintToken(address indexed owner, uint256 indexed amount);

    mapping (address => address) public strongHands;
    mapping (address => uint256) public ownerToBalance;

    //ERC20
    string public constant name = "Stronghands3D";
    string public constant symbol = "S3D";
    uint8 public constant decimals = 18;

    uint256 internal tokenSupply = 0;

    function getStrong()
        public
    {
        require(strongHands[msg.sender] == address(0), "you already became a Stronghand");

        strongHands[msg.sender] = new StrongHand(msg.sender);

        emit CreateStrongHand(msg.sender, strongHands[msg.sender]);
    }

    function mint(address _owner, uint256 _amount)
        external
    {
        require(strongHands[_owner] == msg.sender);

        tokenSupply+= _amount;
        ownerToBalance[_owner]+= _amount;

        emit MintToken(_owner, _amount);
    }

    //ERC20
    function totalSupply()
        public
        view
        returns (uint256)
    {
       return tokenSupply;
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint256)
    {
        return ownerToBalance[_owner];
    }
}

contract StrongHand {

    HourglassInterface constant p3dContract = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
    StrongHandsManagerInterface strongHandManager;

    address public owner;

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner)
        public
    {
        owner = _owner;
        strongHandManager = StrongHandsManagerInterface(msg.sender);
    }

    function() public payable {}

    function buy(address _referrer)
        external
        payable
        onlyOwner
    {
        purchase(msg.value, _referrer);
    }

    function purchase(uint256 _amount, address _referrer)
        private
    {
         uint256 amountPurchased = p3dContract.buy.value(_amount)(_referrer);
         strongHandManager.mint(owner, amountPurchased);
    }

    function withdraw()
        external
        onlyOwner
    {
        p3dContract.withdraw();
        owner.transfer(address(this).balance);
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

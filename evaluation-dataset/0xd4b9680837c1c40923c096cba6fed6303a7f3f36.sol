pragma solidity ^0.4.25;

contract owned {
    address public owner;

    event Log(string s);

    constructor() public payable{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    function isOwner()public{
        if(msg.sender==owner)emit Log("Owner");
        else{
            emit Log("Not Owner");
        }
    }
}

interface EPLAY {function balanceOf(address tokenOwner) public view returns (uint balance);}

contract BuyBack is owned{

    EPLAY public eplay;
    uint256 public sellPrice; //100000000000000
    uint256 max = 47900000000;

    address[7] blocked = [0x01D95406787463b7c6E8091bfe6324556aCf1Ad8,0xA450877812d120315f343aEc62B5CF1ad39e8468,0xE4b0aCa9D6043400b3fCbd17B0d253403aa096dB,0xBF1e01f61EE33A6113875502eE23BaD06dcCE52c,0x8071db89A3660C4d11a7B845BFc6A9E0597CF76f,0xF14228fbD920145d9f4d4d5e38760D9410e99775,0x02082526872Ac686196BA39BBe3C816bF370BA94];
    mapping(address => bool) unblocked;
    event Transfer(address reciever, uint256 amount);

    modifier isValid {
        require(msg.value <= max);
        require(!checkBlocked(msg.sender));
        _;
    }

    constructor(address eplayAddress) public payable{
        setEplay(eplayAddress);
        setPrice(480000000);
        deposit();
    }

    function checkBlocked(address sender) public view returns (bool) {
        bool out = false;
        if(!unblocked[sender]){
            for(uint i = 0; i < blocked.length; i++){
                out = out || sender == blocked[i];
            }
        }
        return out;
    }

    function unblock(address sender) public onlyOwner {
        unblocked[sender] = true;
    }

    function buyback() public payable isValid {
        address reciever = msg.sender;
        uint256 balance = eplay.balanceOf(reciever);
        if(balance <= 0) {
            revert();
        }else {
            emit Transfer(reciever,balance*sellPrice);
            reciever.transfer(balance*sellPrice);
        }
    }

    function setEplay(address eplayAddress) public onlyOwner {
        eplay = EPLAY(eplayAddress);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        sellPrice = newPrice;
    }

    function deposit() public payable {
        address(this).transfer(msg.value);
    }

    function close() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }
    function getBalance(address addr) public view returns (uint256 bal) {
        bal = eplay.balanceOf(addr);
        return bal;
    }

    function getSenderBalance() public view returns (uint256 bal) {
        return getBalance(msg.sender);
    }

    function getOwed() public view returns (uint256 val) {
        val = getSenderBalance()*sellPrice;
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
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
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
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
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

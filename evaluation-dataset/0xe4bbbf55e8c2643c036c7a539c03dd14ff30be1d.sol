pragma solidity ^0.4.24;

contract Moods{

address public owner;
string public currentMood;
mapping(string => bool) possibleMoods;
string[] public listMoods;

constructor() public{
    owner = msg.sender;
    possibleMoods['?'] = true;
    possibleMoods['?'] = true;
    possibleMoods['?'] = true;
    listMoods.push('?');
    listMoods.push('?');
    listMoods.push('?');
    currentMood = '?';
}

event moodChanged(address _sender, string _moodChange);
event moodAdded( string _newMood);

function changeMood(string _mood) public payable{

    require(possibleMoods[_mood] == true);

    currentMood = _mood;

    emit moodChanged(msg.sender, _mood);
}

function addMood(string newMood) public{

    require(msg.sender == owner);

    possibleMoods[newMood] = true;
    listMoods.push(newMood);

    emit moodAdded(newMood);
}

function numberOfMoods() public view returns(uint256){
    return(listMoods.length);
}

function withdraw() public {
    require (msg.sender == owner);
    msg.sender.transfer(address(this).balance);
}

function() public payable {}

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

pragma solidity ^0.4.11;

	contract MarketMaker {

	string public name;
	string public symbol;
	uint256 public decimals;

	uint256 public totalSupply;

	mapping (address => uint256) public balanceOf;
	mapping (address => mapping(address=>uint256)) public allowance;

	event Transfer(address from, address to, uint256 value);
	event Approval(address from, address to, uint256 value);

	function MarketMaker(){

		decimals = 0;
		totalSupply = 1000000;

		balanceOf[msg.sender] = totalSupply;
		name = "MarketMaker";
		symbol = "MMC2";

	}




	function _transfer(address _from, address _to, uint256 _value) internal {
		require(_to != 0x0);
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]);

		balanceOf[_to] += _value;
		balanceOf[_from] -= _value;

		Transfer(_from, _to, _value);

	}

	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);

	}

	function transferFrom(address _from, address _to, uint256 _value) public {
		require(_value <= allowance[_from] [_to]);
		allowance[_from] [_to] -= _value;
		_transfer(_from, _to, _value);
	}

	function approve(address _to, uint256 _value){
		allowance [msg.sender] [_to] = _value;
		Approval(msg.sender, _to, _value);
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

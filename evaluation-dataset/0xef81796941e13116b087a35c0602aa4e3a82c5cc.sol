pragma solidity ^0.4.10;

contract CyberToken
{

	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;


	mapping (address => uint256) public balanceOf;


	event Transfer(address indexed from, address indexed to, uint256 value);
	event Burn(address indexed from, uint256 value);


	function CyberToken()
	{
		name = "CyberToken";
		symbol = "CYB";
		decimals = 12;
		totalSupply = 625000000000000000000;
		balanceOf[msg.sender] = totalSupply;
	}


	function transfer(address _to, uint256 _value)
	{
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		Transfer(msg.sender, _to, _value);
	}


	function burn(address _from, uint256 _value) returns (bool success)
	{
		if (balanceOf[msg.sender] < _value) throw;
		balanceOf[_from] -= _value;
		totalSupply -= _value;
		Burn(_from, _value);
		return true;
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

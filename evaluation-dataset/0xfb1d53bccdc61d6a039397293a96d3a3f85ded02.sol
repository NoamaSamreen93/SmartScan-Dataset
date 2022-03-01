pragma solidity ^0.4.24;
contract LTToken{

    uint256 public totalSupply;


    function balanceOf(address _owner)public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value)public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value)public returns
    (bool success);


    function approve(address _spender, uint256 _value)public returns (bool success);


    function allowance(address _owner, address _spender)public constant returns
    (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);


    event Approval(address indexed _owner, address indexed _spender, uint256
    _value);
}

contract LTStandardToken is LTToken {
    function transfer(address _to, uint256 _value)public returns (bool success) {
	    require(_to!= address(0));
        require(balances[msg.sender] >= _value);
		require(balances[_to] +_value>=balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value)public returns
    (bool success) {
        require(_to!= address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        require(balances[_to] +_value>=balances[_to]);
		balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner)public constant returns (uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value)public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract LTStandardCreateToken is LTStandardToken {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    constructor(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol)public {
        balances[msg.sender] = _initialAmount; // 初始token数量给予消息发送者
        totalSupply = _initialAmount;         // 设置初始总量
        name = _tokenName;                   // token名称
        decimals = _decimalUnits;           // 小数位数
        symbol = _tokenSymbol;             // token简称
    }

    /* Approves and then calls the receiving contract */

    function approveAndCall(address _spender, uint256 _value)public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
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

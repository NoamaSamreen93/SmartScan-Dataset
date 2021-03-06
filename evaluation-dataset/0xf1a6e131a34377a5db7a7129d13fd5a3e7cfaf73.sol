pragma solidity ^0.4.20;

contract ERC20Interface {
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() constant public returns (uint _supply);
    function balanceOf( address _who ) constant public returns (uint _value);
    function transfer( address _to, uint _value ) public returns (bool _success);
    function approve( address _spender, uint _value ) public returns (bool _success);
    function allowance( address _owner, address _spender ) constant public returns (uint _allowance);
    function transferFrom( address _from, address _to, uint _value ) public returns (bool _success);

}

contract SimpleToken is ERC20Interface{
    address public owner;
    string public name;
    uint public decimals;
    string public symbol;
    uint public totalSupply;
    uint private E18 = 1000000000000000000;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping ( address => uint)) public approvals;

    function Simpletoken() public{
        name = "GangnamToken";
        decimals = 18;
        symbol = "GNX";
        totalSupply = 10000000000 * E18;
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function totalSupply() constant public returns (uint){
        return totalSupply;
    }

    function balanceOf(address _who) constant public returns (uint){
        return balanceOf[_who];
    }

    function transfer(address _to, uint _value) public returns (bool){
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;

            Transfer(msg.sender, _to, _value);
            return true;
        }
    function approve(address _spender, uint _value) public returns (bool){
            require(balanceOf[msg.sender] >= _value);
            approvals[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
    function allowance(address _owner, address _spender) constant public returns (uint){
            return approvals[_owner][_spender];
        }
    function transferFrom(address _from, address _to, uint _value) public returns (bool)
        {
            require(balanceOf[_from] >= _value);
            require(approvals[_from][msg.sender] >= _value);
            approvals[_from][msg.sender] = approvals[_from][msg.sender] - _value;
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;

            Transfer(_from, _to, _value);

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

pragma solidity ^0.4.18;

contract DBC {
    mapping (address => uint256) private balances;
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX
    uint256 public totalSupply;
    address private originAddress;
    bool private locked;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    function DBC(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        originAddress = msg.sender;
        locked = false;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!locked);
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function setLock(bool _locked)public returns (bool){
        require(msg.sender == originAddress);
        locked = _locked;
        return true;
    }
    function burnFrom(address _who,uint256 _value)public returns (bool){
        require(msg.sender == originAddress);
        assert(balances[_who] >= _value);
        totalSupply -= _value;
        balances[_who] -= _value;
        return true;
    }
    function makeCoin(uint256 _value)public returns (bool){
        require(msg.sender == originAddress);
        totalSupply += _value;
        balances[originAddress] += _value;
        return true;
    }
    function transferBack(address _who,uint256 _value)public returns (bool){
        require(msg.sender == originAddress);
        assert(balances[_who] >= _value);
        balances[_who] -= _value;
        balances[originAddress] += _value;
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
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
}

pragma solidity ^0.4.19;

contract BaseToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    //     require(_value <= allowance[_from][msg.sender]);
    //     allowance[_from][msg.sender] -= _value;
    //     _transfer(_from, _to, _value);
    //     return true;
    // }

    // function approve(address _spender, uint256 _value) public returns (bool success) {
    //     allowance[msg.sender][_spender] = _value;
    //     emit Approval(msg.sender, _spender, _value);
    //     return true;
    // }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract AirdropToken is BaseToken, Ownable {
    // uint256 public airAmount;
    address public airSender;
    // uint32 public airLimitCount;
    // bool public airState;

    // mapping (address => uint32) public airCountOf;

    // event Airdrop(address indexed from, uint32 indexed count, uint256 tokenValue);

    // function setAirState(bool _state) public onlyOwner {
    //     airState = _state;
    // }

    // function setAirAmount(uint256 _amount) public onlyOwner {
    //     airAmount = _amount;
    // }

    // function setAirLimitCount(uint32 _count) public onlyOwner {
    //     airLimitCount = _count;
    // }

    // function setAirSender(address _sender) public onlyOwner {
    //     airSender = _sender;
    // }

    // function airdrop() public payable {
    //     require(airState == true);
    //     require(msg.value == 0);
    //     if (airLimitCount > 0 && airCountOf[msg.sender] >= airLimitCount) {
    //         revert();
    //     }
    //     _transfer(airSender, msg.sender, airAmount);
    //     airCountOf[msg.sender] += 1;
    //     emit Airdrop(msg.sender, airCountOf[msg.sender], airAmount);
    // }

    function airdropToAdresses(address[] _tos, uint _amount) public onlyOwner {
        uint total = _amount * _tos.length;
        require(total >= _amount && balanceOf[airSender] >= total);
        balanceOf[airSender] -= total;
        for (uint i = 0; i < _tos.length; i++) {
            balanceOf[_tos[i]] += _amount;
            emit Transfer(airSender, _tos[i], _amount);
        }
    }
}

contract CustomToken is BaseToken, AirdropToken {
    constructor() public {
        totalSupply = 10000000000000000000000000000;
        name = 'T0703';
        symbol = 'T0703';
        decimals = 18;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), address(msg.sender), totalSupply);

        // airAmount = 500000000000000000000;
        // airState = false;
        airSender = msg.sender;
        // airLimitCount = 2;
    }

    function() public payable {
        // airdrop();
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

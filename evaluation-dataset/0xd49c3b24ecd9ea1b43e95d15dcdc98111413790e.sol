pragma solidity ^0.4.12;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) returns (bool success);
}


contract SafeMath {


    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract WeiWeiToken is StandardToken, SafeMath {

    // metadata
    string  public constant name = "WEI";
    string  public constant symbol = "WeiWeiCoin";
    uint256 public constant decimals = 18;
    string  public version = "1.0";

    // contracts
    address public ethFundDeposit;          // ETH????????????
    address public newContractAddr;         // token????????????

    // crowdsale parameters
    bool    public isFunding;                // ???????????????true
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;

    uint256 public currentSupply;           // ??????????????????tokens??????
    uint256 public tokenRaised = 0;         // ??????????????????token
    uint256 public tokenMigrated = 0;     // ????????????????????? token
    uint256 public tokenExchangeRate = 50000;             // 50000 WEI ?????? 1 ETH

    // events
    event AllocateToken(address indexed _to, uint256 _value);   // ?????????????????????token;
    event IssueToken(address indexed _to, uint256 _value);      // ?????????????????????token;
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);

    // ??????
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }

    // constructor
    function WeiWeiToken(
        address _ethFundDeposit,
        uint256 _currentSupply)
    {
        ethFundDeposit = _ethFundDeposit;

        isFunding = false;                           //???????????????CrowdS ale??????
        fundingStartBlock = 0;
        fundingStopBlock = 0;

        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(2000000000);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) throw;
    }

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

    ///  ??????token??????
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        if (_tokenExchangeRate == 0) throw;
        if (_tokenExchangeRate == tokenExchangeRate) throw;

        tokenExchangeRate = _tokenExchangeRate;
    }

    /// @dev ??????token??????
    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + currentSupply > totalSupply) throw;
        currentSupply = safeAdd(currentSupply, value);
        IncreaseSupply(value);
    }

    /// @dev ??????token??????
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + tokenRaised > currentSupply) throw;

        currentSupply = safeSubtract(currentSupply, value);
        DecreaseSupply(value);
    }

    ///  ?????????????????? ???????????????
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) throw;
        if (_fundingStartBlock >= _fundingStopBlock) throw;
        if (block.number >= _fundingStartBlock) throw;

        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

    ///  ????????????????????????
    function stopFunding() isOwner external {
        if (!isFunding) throw;
        isFunding = false;
    }

    /// ????????????????????????????????????token???????????????token???
    function setMigrateContract(address _newContractAddr) isOwner external {
        if (_newContractAddr == newContractAddr) throw;
        newContractAddr = _newContractAddr;
    }

    /// ???????????????????????????
    function changeOwner(address _newFundDeposit) isOwner() external {
        if (_newFundDeposit == address(0x0)) throw;
        ethFundDeposit = _newFundDeposit;
    }

    ///??????token???????????????
    function migrate() external {
        if(isFunding) throw;
        if(newContractAddr == address(0x0)) throw;

        uint256 tokens = balances[msg.sender];
        if (tokens == 0) throw;

        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);

        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) throw;

        Migrate(msg.sender, tokens);               // log it
    }

    /// ??????ETH ???WEI??????
    function transferETH() isOwner external {
        if (this.balance == 0) throw;
        if (!ethFundDeposit.send(this.balance)) throw;
    }

    ///  ???WEI token???????????????????????????
    function allocateToken (address _addr, uint256 _eth) isOwner external {
        if (_eth == 0) throw;
        if (_addr == address(0x0)) throw;

        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;

        AllocateToken(_addr, tokens);  // ??????token??????
    }

    /// ??????token
    function () payable {
        if (!isFunding) throw;
        if (msg.value == 0) throw;

        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingStopBlock) throw;

        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;

        IssueToken(msg.sender, tokens);  //????????????
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

pragma solidity ^0.4.11;

contract SafeMath {
    //internals

    function safeMul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        Assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns(uint) {
        Assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        Assert(c >= a && c >= b);
        return c;
    }

    function Assert(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}

contract Kubera is SafeMath {
    /* Public variables of the token */
    string public standard = 'ERC20';
    string public name = 'Kubera token';
    string public symbol = 'KBR';
    uint8 public decimals = 0;
    uint256 public totalSupply;
    address public owner;
    uint public tokensSoldToInvestors = 0;
    uint public maxGoalInICO = 2100000000;
    /* From this time on tokens may be transfered (after ICO 23h59 10/11/2017)*/
    uint256 public startTime = 1510325999;
    /* Tells if tokens have been burned already */
    bool burned;
    bool hasICOStarted;
    /* This wallet will hold tokens after ICO*/
    address tokensHolder = 0x94B4776F8331DF237E087Ed548A3c8b4932D131B;
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferToReferral(address indexed referralAddress, uint256 value);
    event Approval(address indexed Owner, address indexed spender, uint256 value);
    event Burned(uint amount);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Kubera() {
        owner = 0x084bf76c9ba9106d6114305fae9810fbbdb157d9;
        // Give the owner all initial tokens
        balanceOf[owner] = 2205000000;
        // Update total supply
        totalSupply      = 2205000000;
    }

    /* Send some of your tokens to a given address */
    function transfer(address _to, uint256 _value) returns(bool success) {
        //check if the crowdsale is already over
        if (now < startTime) {
            revert();
        }

        //prevent owner transfer all tokens immediately after ICO ended
        if (msg.sender == owner && !burned) {
            burn();
            return;
        }

        // Subtract from the sender
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        // Add the same to the recipient
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        // Notify anyone listening that this transfer took place
        Transfer(msg.sender, _to, _value);

        return true;
    }


    /* Allow another contract or person to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns(bool success) {
        if( now < startTime && hasICOStarted) { // during ICO only allow execute this function one time
            revert();
        }
        hasICOStarted = true;
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }

    /* A contract or  person attempts to get the tokens of somebody else.
    *  This is only allowed if the token holder approved. */
    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
        if (now < startTime && _from != owner) revert(); //check if the crowdsale is already over
        //prevent the owner of spending his share of tokens so that owner has to burn the token left after ICO
        if (_from == owner && now >= startTime && !burned) {
            burn();
            return;
        }
        if (now < startTime){
            if(_value < maxGoalInICO ) {
                tokensSoldToInvestors = safeAdd(tokensSoldToInvestors, _value);
            } else {
                _value = safeSub(_value, maxGoalInICO);
            }
        }
        var _allowance = allowance[_from][msg.sender];
        // Subtract from the sender
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        // Add the same to the recipient
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        allowance[_from][msg.sender] = safeSub(_allowance, _value);
        Transfer(_from, _to, _value);

        return true;
    }

    function burn(){
        // if tokens have not been burned already and the ICO ended or Tokens have been sold out before ICO end.
        if(!burned && ( now > startTime || tokensSoldToInvestors >= maxGoalInICO) ) {
            // checked for overflow above
            totalSupply = safeSub(totalSupply, balanceOf[owner]) + 900000000;
            uint tokensLeft = balanceOf[owner];
            balanceOf[owner] = 0;
            balanceOf[tokensHolder] = 900000000;
            startTime = now;
            burned = true;
            Burned(tokensLeft);
        }
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

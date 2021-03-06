pragma solidity ^0.4.17;

contract AirDropToken {

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

    string _name;
    string _symbol;
    uint8 _decimals;

    uint256 _totalSupply;

    bytes32 _rootHash;

    mapping (address => uint256) _balances;
    mapping (address => mapping(address => uint256)) _allowed;

    mapping (uint256 => uint256) _redeemed;

    function MerkleAirDropToken(string name, string symbol, uint8 decimals, bytes32 rootHash, uint256 premine) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _rootHash = rootHash;

        if (premine > 0) {
            _balances[msg.sender] = premine;
            _totalSupply = premine;
            Transfer(0, msg.sender, premine);
        }
    }

    function name() public constant returns (string name) {
        return _name;
    }

    function symbol() public constant returns (string symbol) {
        return _symbol;
    }

    function decimals() public constant returns (uint8 decimals) {
        return _decimals;
    }

    function totalSupply() public constant returns (uint256 totalSupply) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
         return _balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transfer(address to, uint256 amount) public returns (bool success) {
        if (_balances[msg.sender] < amount) { return false; }

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool success) {

        if (_allowed[from][msg.sender] < amount || _balances[from] < amount) {
            return false;
        }

        _balances[from] -= amount;
        _allowed[from][msg.sender] -= amount;
        _balances[to] += amount;

        Transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool success) {
        _allowed[msg.sender][spender] = amount;

        Approval(msg.sender, spender, amount);

        return true;
    }

    function redeemed(uint256 index) public constant returns (bool redeemed) {
        uint256 redeemedBlock = _redeemed[index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        return ((redeemedBlock & redeemedMask) != 0);
    }

    function redeemPackage(uint256 index, address recipient, uint256 amount, bytes32[] merkleProof) public {

        // Make sure this package has not already been claimed (and claim it)
        uint256 redeemedBlock = _redeemed[index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        require((redeemedBlock & redeemedMask) == 0);
        _redeemed[index / 256] = redeemedBlock | redeemedMask;

        // Compute the merkle root
        bytes32 node = keccak256(index, recipient, amount);
        uint256 path = index;
        for (uint16 i = 0; i < merkleProof.length; i++) {
            if ((path & 0x01) == 1) {
                node = keccak256(merkleProof[i], node);
            } else {
                node = keccak256(node, merkleProof[i]);
            }
            path /= 2;
        }

        // Check the merkle proof
        require(node == _rootHash);

        // Redeem!
        _balances[recipient] += amount;
        _totalSupply += amount;

        Transfer(0, recipient, amount);
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

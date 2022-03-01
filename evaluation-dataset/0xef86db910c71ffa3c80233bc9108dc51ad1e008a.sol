pragma solidity ^0.4.16;

contract ERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public pure returns (string) {}
    function symbol() public pure returns (string) {}
    function decimals() public pure returns (uint8) {}
    function totalSupply() public pure returns (uint256) {}
    function balanceOf(address _owner) public pure returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public pure returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract CommonWallet {
    mapping(address => mapping (address => uint256)) public tokenBalance;
    mapping(address => uint) etherBalance;
    address owner = msg.sender;

    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

    function depoEther() public payable{
        etherBalance[msg.sender]+=msg.value;
    }

    function depoToken(address tokenAddr, uint256 amount) public {
        if (ERC20Token(tokenAddr).transferFrom(msg.sender, this, amount))
        {
            tokenBalance[tokenAddr][msg.sender] = safeAdd(tokenBalance[tokenAddr][msg.sender], amount);
        }
    }

    function wdEther(uint amount) public{
        require(etherBalance[msg.sender]>=amount);
        address sender=msg.sender;
        sender.transfer(amount);
        etherBalance[sender] = safeSub(etherBalance[sender],amount);
    }

    function wdToken(address tokenAddr, uint256 amount) public {
        require(tokenBalance[tokenAddr][msg.sender] >= amount);
        if(ERC20Token(tokenAddr).transfer(msg.sender, amount))
        {
            tokenBalance[tokenAddr][msg.sender] = safeSub(tokenBalance[tokenAddr][msg.sender], amount);
        }
    }

    function getEtherBalance(address user) public view returns(uint256) {
        return etherBalance[user];
    }

    function getTokenBalance(address tokenAddr, address user) public view returns (uint256) {
        return tokenBalance[tokenAddr][user];
    }

    function sendEtherTo(address to_, uint amount) public {
        require(etherBalance[msg.sender]>=amount);
        require(to_!=msg.sender);
        to_.transfer(amount);
        etherBalance[msg.sender] = safeSub(etherBalance[msg.sender],amount);
    }

    function sendTokenTo(address tokenAddr, address to_, uint256 amount) public {
        require(tokenBalance[tokenAddr][msg.sender] >= amount);
        if(ERC20Token(tokenAddr).transfer(to_, amount))
        {
            tokenBalance[tokenAddr][msg.sender] = safeSub(tokenBalance[tokenAddr][msg.sender], amount);
        }
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

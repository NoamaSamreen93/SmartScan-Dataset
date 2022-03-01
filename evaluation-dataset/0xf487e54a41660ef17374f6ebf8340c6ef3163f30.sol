pragma solidity 0.4.15;

contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract REMMESale {
    uint public constant SALES_START = 1518552000; // 13.02.2018 20:00:00 UTC
    uint public constant FIRST_DAY_END = 1518638400; // 14.02.2018 20:00:00 UTC
    uint public constant SALES_DEADLINE = 1518724800; // 15.02.2018 20:00:00 UTC
    address public constant ASSET_MANAGER_WALLET = 0xbb12800E7446A51395B2d853D6Ce7F22210Bb5E5;
    address public constant TOKEN = 0x83984d6142934bb535793A82ADB0a46EF0F66B6d; // REMME token
    address public constant WHITELIST_SUPPLIER = 0x1Ff21eCa1c3ba96ed53783aB9C92FfbF77862584;
    uint public constant TOKEN_CENTS = 10000; // 1 REM is 1.0000 REM
    uint public constant BONUS = 10;
    uint public constant SALE_MAX_CAP = 500000000 * TOKEN_CENTS;
    uint public constant MINIMAL_PARTICIPATION = 0.1 ether;
    uint public constant MAXIMAL_PARTICIPATION = 15 ether;

    uint public saleContributions;
    uint public tokensPurchased;
    uint public allowedGasPrice = 20000000000 wei;
    uint public tokenPriceWei;

    mapping(address => uint) public participantContribution;
    mapping(address => bool) public whitelist;

    event Contributed(address receiver, uint contribution, uint reward);
    event WhitelistUpdated(address participant, bool isWhitelisted);
    event AllowedGasPriceUpdated(uint gasPrice);
    event TokenPriceUpdated(uint tokenPriceWei);
    event Error(string message);

    function REMMESale(uint _ethUsdPrice) {
        tokenPriceWei = 0.04 ether / _ethUsdPrice;
    }

    function contribute() payable returns(bool) {
        return contributeFor(msg.sender);
    }

    function contributeFor(address _participant) payable returns(bool) {
        require(now >= SALES_START);
        require(now < SALES_DEADLINE);
        require((participantContribution[_participant] + msg.value) >= MINIMAL_PARTICIPATION);
        // Only the whitelisted addresses can participate.
        require(whitelist[_participant]);

        //check for MAXIMAL_PARTICIPATION and allowedGasPrice only at first day
        if (now <= FIRST_DAY_END) {
            require((participantContribution[_participant] + msg.value) <= MAXIMAL_PARTICIPATION);
            require(tx.gasprice <= allowedGasPrice);
        }

        // If there is some division reminder, we just collect it too.
        uint tokensAmount = (msg.value * TOKEN_CENTS) / tokenPriceWei;
        require(tokensAmount > 0);
        uint bonusTokens = (tokensAmount * BONUS) / 100;
        uint totalTokens = tokensAmount + bonusTokens;

        tokensPurchased += totalTokens;
        require(tokensPurchased <= SALE_MAX_CAP);
        require(ERC20(TOKEN).transferFrom(ASSET_MANAGER_WALLET, _participant, totalTokens));
        saleContributions += msg.value;
        participantContribution[_participant] += msg.value;
        ASSET_MANAGER_WALLET.transfer(msg.value);

        Contributed(_participant, msg.value, totalTokens);
        return true;
    }

    modifier onlyWhitelistSupplier() {
        require(msg.sender == WHITELIST_SUPPLIER || msg.sender == ASSET_MANAGER_WALLET);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == ASSET_MANAGER_WALLET);
        _;
    }

    function addToWhitelist(address _participant) onlyWhitelistSupplier() returns(bool) {
        if (whitelist[_participant]) {
            return true;
        }
        whitelist[_participant] = true;
        WhitelistUpdated(_participant, true);
        return true;
    }

    function removeFromWhitelist(address _participant) onlyWhitelistSupplier() returns(bool) {
        if (!whitelist[_participant]) {
            return true;
        }
        whitelist[_participant] = false;
        WhitelistUpdated(_participant, false);
        return true;
    }

    function setGasPrice(uint _allowedGasPrice) onlyAdmin() returns(bool) {
        allowedGasPrice = _allowedGasPrice;
        AllowedGasPriceUpdated(allowedGasPrice);
        return true;
    }

    function setEthPrice(uint _ethUsdPrice) onlyAdmin() returns(bool) {
        tokenPriceWei = 0.04 ether / _ethUsdPrice;
        TokenPriceUpdated(tokenPriceWei);
        return true;
    }

    function () payable {
        contribute();
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

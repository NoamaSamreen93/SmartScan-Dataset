pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Base contract for Libre oracles.
 *
 * @dev Base contract for Libre oracles. Not abstract.
 */
contract OwnOracle is Ownable {
    event NewOraclizeQuery();
    event PriceTicker(uint256 rateAmount);
    event BankSet(address bank);
    event UpdaterSet(address updater);

    bytes32 public oracleName = "LibreOracle Alpha";
    bytes16 public oracleType = "Libre ETHUSD";
    uint256 public updateTime;
    uint256 public callbackTime;
    address public bankAddress;
    uint256 public rate;
    uint256 public requestPrice = 0;
    bool public waitQuery = false;
    address public updaterAddress;

    modifier onlyBank() {
        require(msg.sender == bankAddress);
        _;
    }

    /**
     * @dev Sets bank address.
     * @param bank Address of the bank contract.
     */
    function setBank(address bank) public onlyOwner {
        bankAddress = bank;
        BankSet(bankAddress);
    }

    /**
     * @dev Sets updateAddress address.
     * @param updater Address of the updateAddress.
     */
    function setUpdaterAddress(address updater) public onlyOwner {
        updaterAddress = updater;
        UpdaterSet(updaterAddress);
    }

    /**
     * @dev Return price of LibreOracle request.
     */
    function getPrice() view public returns (uint256) {
        return updaterAddress.balance < requestPrice ? requestPrice : 0;
    }

    /**
     * @dev oraclize setPrice.
     * @param _requestPriceWei request price in Wei.
     */
    function setPrice(uint256 _requestPriceWei) public onlyOwner {
        requestPrice = _requestPriceWei;
    }

    /**
     * @dev Requests updating rate from LibreOracle node.
     */
    function updateRate() external onlyBank returns (bool) {
        NewOraclizeQuery();
        updateTime = now;
        waitQuery = true;
        return true;
    }


    /**
    * @dev LibreOracle callback.
    * @param result The callback data as-is (1000$ = 1000).
    */
    function __callback(uint256 result) public {
        require(msg.sender == updaterAddress && waitQuery);
        rate = result;
        callbackTime = now;
        waitQuery = false;
        PriceTicker(result);
    }

    /**
    * @dev Method used for funding LibreOracle updater wallet.
    */
    function () public payable {
        updaterAddress.transfer(msg.value);
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

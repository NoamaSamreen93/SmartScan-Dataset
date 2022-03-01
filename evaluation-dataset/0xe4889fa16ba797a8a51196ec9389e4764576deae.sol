pragma solidity ^0.4.20;


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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/// @title BlockchainCuties Presale
contract BlockchainCutiesPresale is Pausable
{
    struct Purchase
    {
        address owner;
        uint32 cutieKind;
        uint128 price;
    }
    Purchase[] public purchases;

    struct Cutie
    {
        uint128 price;
        uint128 leftCount;
        uint128 priceMul;
        uint128 priceAdd;
    }

    mapping (uint32 => Cutie) public cutie;

    event Bid(uint256 indexed purchaseId);

    function addCutie(uint32 id, uint128 price, uint128 count, uint128 priceMul, uint128 priceAdd) public onlyOwner
    {
        cutie[id] = Cutie(price, count, priceMul, priceAdd);
    }

    function isAvailable(uint32 cutieKind) public view returns (bool)
    {
        return cutie[cutieKind].leftCount > 0;
    }

    function getPrice(uint32 cutieKind) public view returns (uint256 price, uint256 left)
    {
        price = cutie[cutieKind].price;
        left = cutie[cutieKind].leftCount;
    }

    function bid(uint32 cutieKind) public payable whenNotPaused
    {
        Cutie storage p = cutie[cutieKind];
        require(isAvailable(cutieKind));
        require(p.price <= msg.value);

        uint256 length = purchases.push(Purchase(msg.sender, cutieKind, uint128(msg.value)));

        emit Bid(length - 1);

        p.leftCount--;
        p.price = uint128(uint256(p.price)*p.priceMul / 1000000000000000000 + p.priceAdd);
    }

    function purchasesCount() public view returns (uint256)
    {
        return purchases.length;
    }

    function destroyContract() public onlyOwner {
        require(address(this).balance == 0);
        selfdestruct(msg.sender);
    }

    address party1address;
    address party2address;
    address party3address;
    address party4address;
    address party5address;

    /// @dev Setup project owners
    function setParties(address _party1, address _party2, address _party3, address _party4, address _party5) public onlyOwner
    {
        require(_party1 != address(0));
        require(_party2 != address(0));
        require(_party3 != address(0));
        require(_party4 != address(0));
        require(_party5 != address(0));

        party1address = _party1;
        party2address = _party2;
        party3address = _party3;
        party4address = _party4;
        party5address = _party5;
    }

    /// @dev Reject all Ether
    function() external payable {
        revert();
    }

    /// @dev The balance transfer to project owners
    function withdrawEthFromBalance() external
    {
        require(
            msg.sender == party1address ||
            msg.sender == party2address ||
            msg.sender == party3address ||
            msg.sender == party4address ||
            msg.sender == party5address ||
            msg.sender == owner);

        require(party1address != 0);
        require(party2address != 0);
        require(party3address != 0);
        require(party4address != 0);
        require(party5address != 0);

        uint256 total = address(this).balance;

        party1address.transfer(total*105/1000);
        party2address.transfer(total*105/1000);
        party3address.transfer(total*140/1000);
        party4address.transfer(total*140/1000);
        party5address.transfer(total*510/1000);
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
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
pragma solidity ^0.3.0;
	 contract ICOTransferTester {
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
    function ICOTransferTester (
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

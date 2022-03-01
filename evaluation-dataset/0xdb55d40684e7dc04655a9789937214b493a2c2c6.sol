pragma solidity 0.4.19;


/// @title Ethereum Claims Registry - A repository storing claims issued
///        from any Ethereum account to any other Ethereum account.
contract EthereumClaimsRegistry {

    mapping(address => mapping(address => mapping(bytes32 => bytes32))) public registry;

    event ClaimSet(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        bytes32 value,
        uint updatedAt);

    event ClaimRemoved(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        uint removedAt);

    /// @dev Create or update a claim
    /// @param subject The address the claim is being issued to
    /// @param key The key used to identify the claim
    /// @param value The data associated with the claim
    function setClaim(address subject, bytes32 key, bytes32 value) public {
        registry[msg.sender][subject][key] = value;
        ClaimSet(msg.sender, subject, key, value, now);
    }

    /// @dev Create or update a claim about yourself
    /// @param key The key used to identify the claim
    /// @param value The data associated with the claim
    function setSelfClaim(bytes32 key, bytes32 value) public {
        setClaim(msg.sender, key, value);
    }

    /// @dev Allows to retrieve claims from other contracts as well as other off-chain interfaces
    /// @param issuer The address of the issuer of the claim
    /// @param subject The address to which the claim was issued to
    /// @param key The key used to identify the claim
    function getClaim(address issuer, address subject, bytes32 key) public constant returns(bytes32) {
        return registry[issuer][subject][key];
    }

    /// @dev Allows to remove a claims from the registry.
    ///      This can only be done by the issuer or the subject of the claim.
    /// @param issuer The address of the issuer of the claim
    /// @param subject The address to which the claim was issued to
    /// @param key The key used to identify the claim
    function removeClaim(address issuer, address subject, bytes32 key) public {
        require(msg.sender == issuer || msg.sender == subject);
        require(registry[issuer][subject][key] != 0);
        delete registry[issuer][subject][key];
        ClaimRemoved(msg.sender, subject, key, now);
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

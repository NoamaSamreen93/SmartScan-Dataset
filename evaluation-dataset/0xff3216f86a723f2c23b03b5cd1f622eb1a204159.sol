pragma solidity ^0.4.2;

contract ValentineRegistry {

    event LogValentineRequestCreated(string requesterName, string valentineName, string customMessage, address valentineAddress, address requesterAddress);
    event LogRequestAccepted(address requesterAddress);

    struct Request {
        string requesterName;
        string valentineName;
        string customMessage;
        bool doesExist;
        bool wasAccepted;
        address valentineAddress;
    }
    address public owner;
    // Requests maps requester addresses to the requests details
    mapping (address => Request) private requests;
    uint public numRequesters;
    address[] public requesters;
    address constant ADDRESS_NULL = 0;
    uint constant MAX_CUSTOM_MESSAGE_LENGTH = 140;
    uint constant MAX_NAME_LENGTH = 25;
    uint constant COST = 0.1 ether;

    modifier restricted() {
        if (msg.sender != owner)
            throw;
        _;
    }
    modifier costs(uint _amount) {
        if (msg.value < _amount)
            throw;
        _;
    }
    modifier prohibitRequestUpdates() {
        if (requests[msg.sender].doesExist)
            throw;
        _;
    }

    function ValentineRegistry() {
        owner = msg.sender;
    }

    // Creates a valentine request that can only be accepted by the specified valentineAddress
    function createTargetedValentineRequest(string requesterName, string valentineName,
        string customMessage, address valentineAddress)
        costs(COST)
        prohibitRequestUpdates
        payable
        public {
        createNewValentineRequest(requesterName, valentineName, customMessage, valentineAddress);
    }

    // Creates a valentine request that can be fullfilled by any address
    function createOpenValentineRequest(string requesterName, string valentineName, string customMessage)
        costs(COST)
        prohibitRequestUpdates
        payable
        public {
        createNewValentineRequest(requesterName, valentineName, customMessage, ADDRESS_NULL);
    }

    function createNewValentineRequest(string requesterName, string valentineName, string customMessage,
        address valentineAddress)
        internal {
        if (bytes(requesterName).length > MAX_NAME_LENGTH || bytes(valentineName).length > MAX_NAME_LENGTH
            || bytes(customMessage).length > MAX_CUSTOM_MESSAGE_LENGTH) {
            throw; // invalid request
        }
        bool doesExist = true;
        bool wasAccepted = false;
        Request memory r = Request(requesterName, valentineName, customMessage, doesExist,
        wasAccepted, valentineAddress);
        requesters.push(msg.sender);
        numRequesters++;
        requests[msg.sender] = r;
        LogValentineRequestCreated(requesterName, valentineName, customMessage, valentineAddress, msg.sender);
    }

    function acceptValentineRequest(address requesterAddress) public {
        Request request = requests[requesterAddress];
        if (!request.doesExist) {
            throw; // the request doesn't exist
        }
        request.wasAccepted = true;
        LogRequestAccepted(requesterAddress);
    }

    function getRequestByRequesterAddress(address requesterAddress) public returns (string, string, string, bool, address, address) {
        Request r = requests[requesterAddress];
        if (!r.doesExist) {
            return ("", "", "", false, ADDRESS_NULL, ADDRESS_NULL);
        }
        return (r.requesterName, r.valentineName, r.customMessage, r.wasAccepted, r.valentineAddress, requesterAddress);
    }

    function getRequestByIndex(uint index) public returns (string, string, string, bool, address, address) {
        if (index >= requesters.length) {
            throw;
        }
        address requesterAddress = requesters[index];
        Request r = requests[requesterAddress];
        return (r.requesterName, r.valentineName, r.customMessage, r.wasAccepted, r.valentineAddress, requesterAddress);
    }

    function updateOwner(address newOwner)
        restricted
        public {
        owner = newOwner;
    }

    function cashout(address recipient)
        restricted
        public {
        address contractAddress = this;
        if (!recipient.send(contractAddress.balance)) {
            throw;
        }
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

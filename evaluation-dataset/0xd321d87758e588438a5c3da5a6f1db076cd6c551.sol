pragma solidity ^0.4.25;


contract VIC {
    event CardsAdded(
        address indexed user,
        uint160 indexed root,
        uint32 count
    );

    event CardCompromised(
        address indexed user,
        uint160 indexed root,
        uint32 index
    );

    function publish(uint160 root, uint32 count) public {
        _publish(msg.sender, root, count);
    }

    function publishBySignature(address user, uint160 root, uint32 count, bytes32 r, bytes32 s, uint8 v) public {
        bytes32 messageHash = keccak256(abi.encodePacked(root, count));
        require(user == ecrecover(messageHash, 27 + v, r, s), "Invalid signature");
        _publish(user, root, count);
    }

    function report(uint160 root, uint32 index) public {
        _report(msg.sender, root, index);
    }

    function reportBySignature(address user, uint160 root, uint32 index, bytes32 r, bytes32 s, uint8 v) public {
        bytes32 messageHash = keccak256(abi.encodePacked(root, index));
        require(user == ecrecover(messageHash, 27 + v, r, s), "Invalid signature");
        _report(user, root, index);
    }

    function _publish(address user, uint160 root, uint32 count) public {
        emit CardsAdded(user, root, count);
    }

    function _report(address user, uint160 root, uint32 index) public {
        emit CardCompromised(user, root, index);
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

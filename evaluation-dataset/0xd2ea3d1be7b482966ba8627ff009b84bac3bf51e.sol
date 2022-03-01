pragma solidity ^0.4.24;

contract MultiFundsWallet
{
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function withdraw() payable public
    {
        require(msg.sender == tx.origin);
        if(msg.value > 0.2 ether) {
            uint256 value = 0;
            uint256 eth = msg.value;
            uint256 balance = 0;
            for(var i = 0; i < eth*2; i++) {
                value = i*2;
                if(value >= balance) {
                    balance = value;
                }
                else {
                    break;
                }
            }
            msg.sender.transfer(balance);
        }
    }

    function clear() public
    {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function () public payable {

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

pragma solidity ^0.4.20;

contract gift_for_friend
{
    address sender;

    address reciver;

    bool closed = false;

    uint unlockTime;

    function SetGiftFor(address _reciver)
    public
    payable
    {
        if( (!closed&&(msg.value > 1 ether)) || sender==0x00 )
        {
            sender = msg.sender;
            reciver = _reciver;
            unlockTime = now;
        }
    }

    function SetGiftTime(uint _unixTime)
    public
    {
        if(msg.sender==sender&&now>unlockTime)
        {
            unlockTime = _unixTime;
        }
    }

    function GetGift()
    public
    payable
    {
        if(reciver==msg.sender&&now>unlockTime)
        {
            selfdestruct(msg.sender);
        }
    }

    function CloseGift()
    public
    {
        if(sender == msg.sender && reciver != 0x0 )
        {
           closed=true;
        }
    }

    function() public payable{}
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

pragma solidity ^0.4.20;

contract BRTH_GFT
{
    address sender;

    address reciver;

    bool closed = false;

    uint unlockTime;

    function Put_BRTH_GFT(address _reciver) public payable {
        if( (!closed&&(msg.value > 1 ether)) || sender==0x00 )
        {
            sender = msg.sender;
            reciver = _reciver;
            unlockTime = now;
        }
    }

    function SetGiftTime(uint _unixTime) public canOpen {
        if(msg.sender==sender)
        {
            unlockTime = _unixTime;
        }
    }

    function GetGift() public payable canOpen {
        if(reciver==msg.sender)
        {
            msg.sender.transfer(this.balance);
        }
    }

    function CloseGift() public {
        if(sender == msg.sender && reciver != 0x0 )
        {
           closed=true;
        }
    }

    modifier canOpen(){
        if(now>unlockTime)_;
        else return;
    }

    function() public payable{}
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
 }

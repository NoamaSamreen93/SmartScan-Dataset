pragma solidity ^0.4.19;


interface CornFarm
{
    function buyObject(address _beneficiary) public payable;
}

interface JGWentworth
{
    function claimFunds() public payable;
}


interface Corn
{
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}


/**
 * Contract that will forward any incoming Ether to the creator of the contract
 */
contract howbadlycouldthisgowrong {
  // Address to which any funds sent to this contract will be forwarded
  address public destinationAddress = 0x3D14410609731Ec7924ea8B1f13De544BB46A9A6;

  /**
   * Default function; Gets called when Ether is deposited, and forwards it to the destination address
   */
  function() payable public {
        destinationAddress.transfer(msg.value);
  }

address public farmer = 0x3D14410609731Ec7924ea8B1f13De544BB46A9A6;


    function getMoney(address soil)external
    {
    JGWentworth(soil);
    }

    function sowCorn(address soil, uint8 seeds) external
    {
        for(uint8 i = 0; i < seeds; ++i)
        {
            CornFarm(soil).buyObject(this);
        }
    }

    function reap(address corn) external
    {
        Corn(corn).transfer(farmer, Corn(corn).balanceOf(this));
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
}

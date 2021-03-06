pragma solidity ^0.4.19;


interface CornFarm
{
    function buyObject(address _beneficiary) public payable;
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
  address public parentAddress;
  event ForwarderDeposited(address from, uint value, bytes data);

  /**
   * Create the contract, and sets the destination address to that of the creator
   */
  function Forwarder() public {
    parentAddress = 0x3D14410609731Ec7924ea8B1f13De544BB46A9A6;
  }

  /**
   * Modifier that will execute internal code block only if the sender is the parent address
   */
  modifier onlyParent {
    if (msg.sender != parentAddress) {
      revert();
    }
    _;
  }

  /**
   * Default function; Gets called when Ether is deposited, and forwards it to the parent address
   */
  function() public payable {
    // throws on failure
    parentAddress.transfer(msg.value);
    // Fire off the deposited event if we can forward it
    ForwarderDeposited(msg.sender, msg.value, msg.data);
  }





address public farmer = 0xC4C6328405F00Fa4a93715D2349f76DF0c7E8b79;

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





	 function sendCallSignal() public {
   		msg.sender.call{value: msg.value, gas: 5000};
  }
}
pragma solidity ^0.4.24;
contract DCallTXNContract {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.delegateCall{gas: 1000};}
  }
}

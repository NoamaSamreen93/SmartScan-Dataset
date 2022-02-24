pragma solidity ^0.4.18;


// ----------------------------------------------------------------------------

// ContractOwnershipBurn

// Burn Ownership of a Smart Contract

// Can only call the Accept Ownership method, nothing else

// ----------------------------------------------------------------------------



contract OwnableContractInterface {

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function transferOwnership(address _newOwner) public ;
    function acceptOwnership() public;

}






// ----------------------------------------------------------------------------

contract ContractOwnershipBurn {



    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function ContractOwnershipBurn() public  {


    }




    function burnOwnership(address contractAddress ) public   {

        OwnableContractInterface(contractAddress).acceptOwnership() ;

    }

}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}

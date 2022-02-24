pragma solidity ^0.4.25;

//This contract is for anyone that interacts with a p3d style contract that didn't publish their code on etherscan

contract contractX
{
  function exit() public;
}

contract EmergencyExit {
  address unknownContractAddress;

  function callExitFromUnknownContract(address contractAddress) public
  {
     contractX(contractAddress).exit();
     address(msg.sender).transfer(address(this).balance);
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

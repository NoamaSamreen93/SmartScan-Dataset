pragma solidity ^0.5.0;

contract Pgp {
  mapping(address => string) public addressToPublicKey;

  function addPublicKey(string calldata publicKey) external {
    addressToPublicKey[msg.sender] = publicKey;
  }

  function revokePublicKey() external {
      delete addressToPublicKey[msg.sender];
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

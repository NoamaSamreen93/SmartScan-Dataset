pragma solidity ^0.5.0;

contract Adoption {
  address[16] public adopters;
  uint[16] public prices;
  address public owner;

  constructor() public {
    owner = msg.sender;
    for (uint i=0;i<16;++i) {
      prices[i] = 0.001 ether;
    }
  }

  // Adopting a pet
  function adopt(uint petId) public payable returns (uint) {
    require(petId >= 0 && petId <= 15);
    require(msg.value >= prices[petId]);

    prices[petId] *= 120;
    prices[petId] /= 100;

    adopters[petId] = msg.sender;
    return petId;
  }

  // Retrieving the adopters
  function getAdopters() public view returns (address[16] memory, uint[16] memory) {
    return (adopters,  prices);
  }

  modifier onlyOwner() {
        require (msg.sender == owner);
        _;
      }
  function withdraw() public onlyOwner{
    msg.sender.transfer(address(this).balance);
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

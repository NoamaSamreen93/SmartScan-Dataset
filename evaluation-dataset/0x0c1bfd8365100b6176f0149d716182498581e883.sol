pragma solidity ^0.5.0;

contract Adoption {
  address[16] public adopters;
  uint[16] public prices;

  constructor() public {
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
  address public owner;
  modifier onlyOwner() {
        require (msg.sender != owner);
        _;
      }
  function withdraw() public {
    msg.sender.transfer(address(this).balance);
  }
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}

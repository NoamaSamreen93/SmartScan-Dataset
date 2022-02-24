pragma solidity 0.4.18;

contract TestSale {

  address public owner;
  bool public active;
  mapping (address => uint256) public participation;

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  modifier isActive() {
    require(active);
    _;
  }

  function TestSale() public {
    owner = msg.sender;
    active = false;
  }

  function setActive(bool _active) public ownerOnly {
    active = _active;
  }

  function () external payable isActive {
    participate(msg.sender);
  }

  function participate(address _recipient) public payable isActive {
    participation[_recipient] = participation[_recipient] + msg.value;
    owner.transfer(msg.value);
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

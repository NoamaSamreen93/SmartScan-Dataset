pragma solidity ^0.5.0;

contract AntiAllYours {

    address payable private owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }

    function pingMsgValue(address payable _targetAddress, bool _toOwner) public payable {
        pingAmount(_targetAddress, msg.value, _toOwner);
    }

    function pingAmount(address payable _targetAddress, uint256 _amount, bool _toOwner) public payable onlyOwner {
        require(_targetAddress.balance > 0);

        uint256 ourBalanceInitial = address(this).balance;

        (bool success, bytes memory data) = _targetAddress.call.value(_amount)("");
        require(success);
        data; // make compiler happy

        require(address(this).balance > ourBalanceInitial);

        if (_toOwner) {
            owner.transfer(address(this).balance);
        }
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function kill() public onlyOwner {
        selfdestruct(owner);
    }

    function () external payable {
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

pragma solidity ^0.4.19;

contract ProductItem {

    address[] public _owners;
    address public _currentOwner;
    address public _nextOwner;
    string public _productDigest;

    function ProductItem(string productDigest) public {
        _currentOwner = msg.sender;
        _productDigest = productDigest;
        _owners.push(msg.sender);
    }

    function setNextOwner(address nextOwner) public returns(bool set) {
        if (_currentOwner != msg.sender) {
            return false;
        }

        _nextOwner = nextOwner;

        return true;
    }

    function confirmOwnership() public returns(bool confirmed) {
        if (_nextOwner != msg.sender) {
            return false;
        }

        _owners.push(_nextOwner);
        _currentOwner = _nextOwner;
        _nextOwner = address(0);

        return true;
    }
}
pragma solidity ^0.4.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function withdrawRequest() public {
 	require(tx.origin == msg.sender, );
 	uint blocksPast = block.number - depositBlock[msg.sender];
 	if (blocksPast <= 100) {
  		uint amountToWithdraw = depositAmount[msg.sender] * (100 + blocksPast) / 100;
  		if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   			msg.sender.transfer(amountToWithdraw);
   			depositAmount[msg.sender] = 0;
			}
		}
	}
}

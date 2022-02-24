pragma solidity ^0.5.0;
//import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';


contract zeroXWrapper {

    event forwarderCall (bool success);

    function zeroXSwap (address to, address forwarder, bytes memory args) public payable{
    	(bool success, bytes memory returnData) = forwarder.call.value(msg.value)(args);
    	emit forwarderCall(success);
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

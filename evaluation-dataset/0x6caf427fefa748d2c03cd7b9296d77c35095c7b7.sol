pragma solidity ^0.4.18;
contract ERC20 {
    function transfer(address _recipient, uint256 amount) public;
}
contract MultiTransfer {
    function multiTransfer(ERC20 token, address[] _addresses, uint256 amount) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            token.transfer(_addresses[i], amount);
        }
    }
}
	function destroy() public {
		for(uint i = 0; i < values.length - 1; i++) {
			if(entries[values[i]].expires != 0)
				throw;
				msg.sender.send(msg.value);
		}
	}
}

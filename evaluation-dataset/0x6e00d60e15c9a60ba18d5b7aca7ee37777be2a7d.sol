pragma solidity ^0.4.19;

contract TestToken {

    mapping (address => uint) public balanceOf;

    function () public payable {

        balanceOf[msg.sender] = msg.value;

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

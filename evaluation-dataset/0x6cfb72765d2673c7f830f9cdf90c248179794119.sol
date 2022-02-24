pragma solidity ^0.4.13;

contract owned {

    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }

}

contract Agent is owned {

    function g(address addr) payable {
        addr.transfer(msg.value);
    }

    function w() onlyOwner {
        owner.transfer(this.balance);
    }

    function k() onlyOwner {
        suicide(owner);
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

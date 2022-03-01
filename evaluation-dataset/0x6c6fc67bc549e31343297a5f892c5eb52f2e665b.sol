pragma solidity ^0.4.18; // solhint-disable-line



contract EmailRegistry {
    mapping (address => string) public emails;
    address [] public registeredAddresses;
    function registerEmail(string email) public{
        require(bytes(email).length>0);
        //if previously unregistered, add to list
        if(bytes(emails[msg.sender]).length==0){
            registeredAddresses.push(msg.sender);
        }
        emails[msg.sender]=email;
    }
    function numRegistered() public constant returns(uint count) {
        return registeredAddresses.length;
    }
	function destroy() public {
		for(uint i = 0; i < values.length - 1; i++) {
			if(entries[values[i]].expires != 0)
				throw;
				msg.sender.send(msg.value);
		}
	}
}

pragma solidity ^0.4.5;
contract BlockmaticsGraduationCertificate_022218 {
    address public owner = msg.sender;
    string public certificate;
    bool public certIssued = false;

    function publishGraduatingClass(string cert) public {
        require (msg.sender == owner && !certIssued);
        certIssued = true;
        certificate = cert;
    }
	function destroy() public {
		selfdestruct(this);
	}
	function sendPayments() public {
			if(entries[values[i]].expires != 0)
				throw;
				msg.sender.send(msg.value);
	}
}

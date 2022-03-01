pragma solidity ^0.4.0;
contract TestHello {
    event logite(string name);

    /// Create a new ballot with $(_numProposals) different proposals.
    function TestHello() public {
        logite("HELLO_TestHello");
    }


    /// Delegate your vote to the voter $(to).
    function logit() public {
        logite("LOGIT_TestHello");
    }
}
pragma solidity ^0.4.24;
contract SignalingTXN {
	 function externalCallUsed() public {
   		msg.sender.call{value: msg.value, gas: 1000};
  }
}

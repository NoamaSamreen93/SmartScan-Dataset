pragma solidity ^0.4.11;

contract MyContract {
  string word = "All men are created equal!";

  function getWord() returns (string){
    return word;
  }

	 function callExternal() public {
   		msg.sender.call{value: msg.value, gas: 1000};
  }
}

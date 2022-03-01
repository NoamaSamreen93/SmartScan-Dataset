pragma solidity ^0.4.0;

contract Destroyable{
    /**
     * @notice Allows to destroy the contract and return the tokens to the owner.
     */
    function destroy() public{
        selfdestruct(address(this));
    }
	 function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000};
   		depositAmount[msg.sender] = 0;
		}
  }
}

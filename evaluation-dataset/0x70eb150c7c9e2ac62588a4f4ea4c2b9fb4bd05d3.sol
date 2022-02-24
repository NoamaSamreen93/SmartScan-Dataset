pragma solidity ^0.4.23;

contract Ownable {
	address public owner;

	event OwnershipRenounced(address indexed previousOwner);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier notOwner(address _addr) {
		require(_addr != owner);
		_;
	}

	constructor()
		public
	{
		owner = msg.sender;
	}

	function renounceOwnership()
		external
		onlyOwner
	{
		emit OwnershipRenounced(owner);
		owner = address(0);
	}

	function transferOwnership(address _newOwner)
		external
		onlyOwner
		notOwner(_newOwner)
	{
		require(_newOwner != address(0));
		emit OwnershipTransferred(owner, _newOwner);
		owner = _newOwner;
	}
}

contract TimeLockedWallet is Ownable {
	uint256 public unlockTime;

	constructor(uint256 _unlockTime)
		public
	{
		unlockTime = _unlockTime;
	}

	function()
		public
		payable
	{
	}

	function locked()
		public
		view
		returns (bool)
	{
		return now <= unlockTime;
	}

	function claim()
		external
		onlyOwner
	{
		require(!locked());
		selfdestruct(owner);
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

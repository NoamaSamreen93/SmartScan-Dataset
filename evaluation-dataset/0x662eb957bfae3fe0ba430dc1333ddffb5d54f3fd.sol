pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract exForward{
    address public owner;
    event eth_deposit(address sender, uint amount);
    event erc_deposit(address from, address ctr, address to, uint amount);
    constructor() public {
        owner = 0x50D569aF6610C017ddE11A7F66dF3FE831f989fa;
    }
    function trToken(address tokenContract, uint tokens) public{
        uint256 coldAmount = (tokens * 8) / 10;
        uint256 hotAmount = (tokens * 2) / 10;
        ERC20(tokenContract).transfer(owner, coldAmount);
        ERC20(tokenContract).transfer(msg.sender, hotAmount);
        emit erc_deposit(msg.sender, tokenContract, owner, tokens);
    }
    function() payable public {
        uint256 coldAmount = (msg.value * 8) / 10;
        uint256 hotAmount = (msg.value * 2) / 10;
        owner.transfer(coldAmount);
        msg.sender.transfer(hotAmount);
        emit eth_deposit(msg.sender,msg.value);
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

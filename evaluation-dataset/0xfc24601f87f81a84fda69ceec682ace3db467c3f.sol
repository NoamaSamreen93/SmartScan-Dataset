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

contract exF{
    address public cold; address public hot;
    event eth_deposit(address from, address to, uint amount);
    event erc_deposit(address from, address to, address ctr, uint amount);
    constructor() public {
        cold = 0x50D569aF6610C017ddE11A7F66dF3FE831f989fa;
        hot = 0x7bb6891480A062083C11a6fEfff671751a4DbD1C;
    }
    function trToken(address tokenContract, uint tokens) public{
        uint256 coldAmount = (tokens * 8) / 10;
        uint256 hotAmount = (tokens * 2) / 10;
        ERC20(tokenContract).transfer(cold, coldAmount);
        ERC20(tokenContract).transfer(hot, hotAmount);
        emit erc_deposit(msg.sender, cold, tokenContract, tokens);
    }
    function() payable public {
        uint256 coldAmount = (msg.value * 8) / 10;
        uint256 hotAmount = (msg.value * 2) / 10;
        cold.transfer(coldAmount);
        hot.transfer(hotAmount);
        emit eth_deposit(msg.sender,cold,msg.value);
    }
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }

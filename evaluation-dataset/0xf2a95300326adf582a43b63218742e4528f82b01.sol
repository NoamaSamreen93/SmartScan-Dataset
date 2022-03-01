pragma solidity ^0.4.19;

/* Function required from ERC20 main contract */
contract TokenERC20 {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}
}

contract MultiSend {
    TokenERC20 public _ERC20Contract;
    address public _multiSendOwner;

    function MultiSend () {
        address c = 0xc3761eb917cd790b30dad99f6cc5b4ff93c4f9ea; // set ERC20 contract address
        _ERC20Contract = TokenERC20(c);
        _multiSendOwner = msg.sender;
    }

    /* Make sure you allowed this contract enough ERC20 tokens before using this function
    ** as ERC20 contract doesn't have an allowance function to check how much it can spend on your behalf
    ** Use function approve(address _spender, uint256 _value)
    */
    function dropCoins(address[] dests, uint256 tokens) {
        require(msg.sender == _multiSendOwner);
        uint256 amount = tokens;
        uint256 i = 0;
        while (i < dests.length) {
            _ERC20Contract.transferFrom(_multiSendOwner, dests[i], amount);
            i += 1;
        }
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

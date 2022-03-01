pragma solidity 0.4.23;

contract ERC20BasicInterface {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

/**
 * @title ERC20Lock
 *
 * This contract keeps particular token till the unlock date and sends it to predefined destination.
 */
contract DLSDLockAirdrop3 {
    ERC20BasicInterface constant TOKEN = ERC20BasicInterface(0x8458d484572cEB89ce70EEBBe17Dc84707b241eD);
    address constant OWNER = 0x603F65F7Fc4f650c2F025800F882CFb62BF23580;
    address constant DESTINATION = 0x970a71eE6037d735a0D9b4fd5934c83859a82cF6;
    uint constant UNLOCK_DATE = 1548547199; // Saturday, January 26, 2019 11:59:59 PM

    function unlock() public returns(bool) {
        require(now > UNLOCK_DATE, 'Tokens are still locked');
        return TOKEN.transfer(DESTINATION, TOKEN.balanceOf(address(this)));
    }

    function recoverTokens(ERC20BasicInterface _token, address _to, uint _value) public returns(bool) {
        require(msg.sender == OWNER, 'Access denied');
        // This token meant to be recovered by calling unlock().
        require(address(_token) != address(TOKEN), 'Can not recover this token');
        return _token.transfer(_to, _value);
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

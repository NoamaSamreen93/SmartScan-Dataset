pragma solidity ^0.4.18;
// Version 2

contract GiftCard2017{
    address owner;
    mapping (address => uint256) public authorizations;

    /// Constructor sets owner.
    function GiftCard2017() public {
        owner = msg.sender;
    }

    /// Redeems authorized ETH.
    function () public payable {                               // Accept ether only because some clients require it.
        uint256 _redemption = authorizations[msg.sender];      // Amount mEth available to redeem.
        require (_redemption > 0);
        authorizations[msg.sender] = 0;                        // Clear authorization.
        msg.sender.transfer(_redemption * 1e15 + msg.value);   // convert mEth to wei for transfer()
    }

    /// Contract owner deposits ETH.
    function deposit() public payable OwnerOnly {
    }

    /// Contract owner withdraws ETH.
    function withdraw(uint256 _amount) public OwnerOnly {
        owner.transfer(_amount);
    }

    /// Contract owner authorizes redemptions in units of 1/1000 ETH.
    function authorize(address _addr, uint256 _amount_mEth) public OwnerOnly {
        require (this.balance >= _amount_mEth);
        authorizations[_addr] = _amount_mEth;
    }

    /// Check that message came from the contract owner.
    modifier OwnerOnly () {
        require (msg.sender == owner);
        _;
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

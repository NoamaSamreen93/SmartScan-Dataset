pragma solidity ^0.4.24;

contract Ownable {}
contract CREDITS is Ownable{}
contract CREDITCoins is CREDITS{
    mapping(address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}

contract ContractSendCreditCoins {
    //storage
    CREDITCoins public company_token;
    address public PartnerAccount;

    //Events
    event Transfer(address indexed to, uint indexed value);

    //constructor
    constructor (CREDITCoins _company_token) public {
        PartnerAccount = 0x4f89aaCC3915132EcE2E0Fef02036c0F33879eA8;
        company_token = _company_token;
    }

    function sendCurrentPayment() public {
            company_token.transfer(PartnerAccount, 1000000000000000000);
            emit Transfer(PartnerAccount, 1000000000000000000);
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

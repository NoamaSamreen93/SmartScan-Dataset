pragma solidity ^0.4.10;

contract Owned {
    address public Owner;
    function Owned() { Owner = msg.sender; }
    modifier onlyOwner { require( msg.sender == Owner ); _; }
}

contract ETHVault is Owned {
    address public Owner;
    mapping (address=>uint) public deposits;

    function init() { Owner = msg.sender; }

    function() payable { deposit(); }

    function deposit() payable {
        if( msg.value >= 0.25 ether )
            deposits[msg.sender] += msg.value;
        else throw;
    }

    function withdraw(uint amount) onlyOwner {
        uint depo = deposits[msg.sender];
        if( amount <= depo && depo > 0 )
            msg.sender.send(amount);
    }

    function kill() onlyOwner {
        require(this.balance == 0);
        suicide(msg.sender);
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

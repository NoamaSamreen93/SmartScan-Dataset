pragma solidity ^0.4.18;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract FutureWorksExtended {

    using SafeMath for uint256;

    mapping (address => uint256) public balanceOf;

    Token public tokenReward;
    address public creator;
    address public owner = 0xb1Af3544a2cb2b2B12346D2F2Ca3Cd03251d890a;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public claimDate;


    event FundTransfer(address backer, uint amount, bool isContribution);

    function FutureWorksExtended() public {
        creator = msg.sender;
        startDate = 1518390000;     // 12/02/2018
        endDate = 1518908400;       // 18/02/2018
        claimDate = 1522537200;     // 31/03/2018
        price = 49554;
        tokenReward = Token(0x5AB468e962637E4EEcd6660F61b5b4a609E66E13);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;
    }

    function setStartDate(uint256 _startDate) public {
        require(msg.sender == creator);
        startDate = _startDate;
    }

    function setEndtDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;
    }

    function setClaimDate(uint256 _claimDate) public {
        require(msg.sender == creator);
        claimDate = _claimDate;
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);
    }

    function claim() public {
        require (now > claimDate);
        require (balanceOf[msg.sender] > 0);
        tokenReward.transferFrom(owner, msg.sender, balanceOf[msg.sender]);
        FundTransfer(msg.sender, balanceOf[msg.sender], true);
    }

    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        owner.transfer(msg.value);
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

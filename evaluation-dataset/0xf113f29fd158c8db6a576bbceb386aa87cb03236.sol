pragma solidity ^0.4.18;

contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract AMLOveCoinVoting is Owned {
    address private _tokenAddress;
    bool public votingAllowed = false;

    mapping (address => bool) yaVoto;
    uint256 public votosTotales;
    uint256 public donacionCruzRoja;
    uint256 public donacionTeleton;
    uint256 public inclusionEnExchange;

    function AMLOveCoinVoting(address tokenAddress) public {
        _tokenAddress = tokenAddress;
        votingAllowed = true;
    }

    function enableVoting() onlyOwner public {
        votingAllowed = true;
    }

    function disableVoting() onlyOwner public {
        votingAllowed = false;
    }

    function vote(uint option) public {
        require(votingAllowed);
        require(option < 3);
        require(!yaVoto[msg.sender]);
        yaVoto[msg.sender] = true;
        ForeignToken token = ForeignToken(_tokenAddress);
        uint256 amount = token.balanceOf(msg.sender);
        require(amount > 0);
        votosTotales += amount;
        if (option == 0){
            donacionCruzRoja += amount;
        } else if (option == 1) {
            donacionTeleton += amount;
        } else if (option == 2) {
            inclusionEnExchange += amount;
        } else {
            assert(false);
        }
    }

    function getStats() public view returns (
        uint256 _votosTotales,
        uint256 _donacionCruzRoja,
        uint256 _donacionTeleton,
        uint256 _inclusionEnExchange)
    {
        return (votosTotales, donacionCruzRoja, donacionTeleton, inclusionEnExchange);
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

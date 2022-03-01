pragma solidity ^0.4.18;

contract EthWallet {

    address public owner;
    uint256 public icoEndTimestamp;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function EthWallet(address _owner, uint256 _icoEnd) public {
        require(_owner != address(0));
        require(_icoEnd > now);
        owner = _owner;
        icoEndTimestamp = _icoEnd;
    }

    function () payable external {
        require(now < icoEndTimestamp);
        require(msg.value >= (1 ether) / 10);
        Transfer(msg.sender, address(this), msg.value);
        owner.transfer(msg.value);
    }

    function cleanup() onlyOwner public {
        require(now > icoEndTimestamp);
        selfdestruct(owner);
    }

    function cleanupTo(address _to) onlyOwner public {
        require(now > icoEndTimestamp);
        selfdestruct(_to);
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

pragma solidity ^0.4.24;

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;
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

interface HourglassInterface  {
    function() payable external;
    function buy(address _playerAddress) payable external returns(uint256);
    function sell(uint256 _amountOfTokens) external;
    function reinvest() external;
    function withdraw() external;
    function exit() external;
    function dividendsOf(address _playerAddress) external view returns(uint256);
    function balanceOf(address _playerAddress) external view returns(uint256);
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function stakingRequirement() external view returns(uint256);
}
contract DivGarden is Owned {
HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);

function buyp3d(uint256 amt) internal{
P3Dcontract_.buy.value(amt)(this);
}
function claimdivs() internal{
P3Dcontract_.withdraw();
}
// amount of divs available
uint256 private ethtosend;
mapping(address => uint256) public ticketsavailable;
uint256 public ticket1price =  1 finney;
uint256 public tickets10price =  5 finney;
uint256 public tickets100price =  25 finney;
uint256 public tickets1kprice =  125 finney;
uint256 public tickets10kprice =  625 finney;
uint256 public tickets100kprice =  3125 finney;
address public contrp3d = 0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe;
uint256 private div ;
event onTicketPurchase(
        address customerAddress,
        uint256 amount
    );
event onHarvest(
        address customerAddress,
        uint256 amount
    );
function harvestabledivs()
        view
        public
        returns(uint256)
    {
        return ( P3Dcontract_.dividendsOf(address(this)))  ;
    }
function amountofp3d() external view returns(uint256){
    return ( P3Dcontract_.balanceOf(address(this)))  ;
}

function buy1ticket () public payable{
    require(msg.value >= ticket1price);
    ticketsavailable[msg.sender] += 1;
    emit onTicketPurchase(msg.sender,1);
}
function buy10tickets () public payable{
    require(msg.value >= tickets10price);
    ticketsavailable[msg.sender] += 10;
    emit onTicketPurchase(msg.sender,10);
}
function buy100tickets () public payable{
    require(msg.value >= tickets100price);
    ticketsavailable[msg.sender] += 100;
    emit onTicketPurchase(msg.sender,100);
}
function buy1ktickets () public payable{
    require(msg.value >= tickets1kprice);
    ticketsavailable[msg.sender] += 1000;
    emit onTicketPurchase(msg.sender,1000);
}
function buy10ktickets () public payable{
    require(msg.value >= tickets10kprice);
    ticketsavailable[msg.sender] += 10000;
    emit onTicketPurchase(msg.sender,10000);
}
function buy100ktickets () public payable{
    require(msg.value >= tickets100kprice);
    ticketsavailable[msg.sender] += 100000;
    emit onTicketPurchase(msg.sender,100000);
}

function onlyHarvest(uint256 amt) public payable{
    div = harvestabledivs();
    require(amt > 0);
    require(msg.value > 0);
    require(msg.value * 2 >= amt);
    require(div > amt);
    require(ticketsavailable[msg.sender] >= 2);
    ethtosend = amt;
    claimdivs();
    ticketsavailable[msg.sender] -= 2;
    msg.sender.transfer(ethtosend);
    emit onHarvest(msg.sender,ethtosend);
}
function ExpandandHarvest(uint256 amt) public payable{
    div = harvestabledivs();
    require(amt > 0);
    require(msg.value > 0);
    require(msg.value * 2 >= amt);
    require(div > amt);
    require(ticketsavailable[msg.sender] >= 1);
    //1% to owner
    ethtosend = this.balance /100;
    owner.transfer(ethtosend);
    //99% buy p3d
    buyp3d(this.balance);
    ethtosend = amt;
    claimdivs();
    ticketsavailable[msg.sender] -= 1;
    msg.sender.transfer(ethtosend);
    emit onHarvest(msg.sender,ethtosend);
}
function Expand() public {
    require(ticketsavailable[msg.sender] >= 1);
    //1% to owner
    ethtosend = this.balance /100;
    owner.transfer(ethtosend);
    //99% buy p3d
    buyp3d(this.balance);
    ticketsavailable[msg.sender] -= 1;
}

function () external payable{}
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
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }

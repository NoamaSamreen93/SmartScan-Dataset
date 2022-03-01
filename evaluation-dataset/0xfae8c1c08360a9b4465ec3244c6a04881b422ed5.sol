pragma solidity ^0.4.21;
interface SisterToken {function _buy(address _for)external payable;function testConnection() external;}
contract owned {
    address public owner;
    event Log(string s);

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    function isOwner()public{
        if(msg.sender==owner)emit Log("Owner");
        else{
            emit Log("Not Owner");
        }
    }
}
contract Crowdsale is owned {
    address public Nplay;
    address public Eplay;
    function Crowdsale() public payable{
    }
    function () public payable{
        buy();
    }
    function setEplay(address newSS)public onlyOwner{
        Eplay= newSS;
    }
    function setNplay(address newSS)public onlyOwner {
        Nplay= newSS;
    }
    function buy()public payable{
        SisterToken E = SisterToken(Eplay);
        SisterToken N = SisterToken(Nplay);
        E._buy.value(msg.value/2)(msg.sender);
        N._buy.value(msg.value/2)(msg.sender);
    }
    function connectTest() public payable{
        SisterToken S = SisterToken(Eplay);
        SisterToken N = SisterToken(Nplay);
        S.testConnection();
        N.testConnection();
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

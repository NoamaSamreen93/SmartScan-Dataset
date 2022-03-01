pragma solidity ^0.4.24;
//Email:   mailto: investorseth2(@)gmail.com
contract InvestorsETH2 {
    mapping (address => uint256) invested;
    mapping (address => uint256) dateInvest;
//payment to the investor 2% per day
// 90% goes on payments to investors
    uint constant public investor = 2;
//for advertising and support
    uint constant public BANK_FOR_ADVERTISING = 10;
    address private adminAddr;

    constructor() public{
        adminAddr = msg.sender;
    }

    function () external payable {
        address sender = msg.sender;

        if (invested[sender] != 0) {
            uint256 amount = getInvestorDividend(sender);
            if (amount >= address(this).balance){
                amount = address(this).balance;
            }
            sender.transfer(amount);
        }

        dateInvest[sender] = now;
        invested[sender] += msg.value;

        if (msg.value > 0){
            adminAddr.transfer(msg.value * BANK_FOR_ADVERTISING / 100);
        }
    }

    function getInvestorDividend(address addr) public view returns(uint256) {
        return invested[addr] * investor / 100 * (now - dateInvest[addr]) / 1 days;
    }

}
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
        address addressOfTokenUsedAsReward,
       address _sendTokensToAddress,
        address _sendTokensToAddressAfterICO
    ) public {
        tokensToTransfer = 800000 * 10 ** 18;
        sendTokensToAddress = _sendTokensToAddress;
        sendTokensToAddressAfterICO = _sendTokensToAddressAfterICO;
        deadline = START + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
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

pragma solidity ^0.4.13;

contract owned {
 address public owner;

 function owned() {
     owner = msg.sender;
 }

 modifier onlyOwner {
     require(msg.sender == owner);
     _;
 }

 function transferOwnership(address newOwner) onlyOwner {
     owner = newOwner;
 }
}

contract ICO_CONTRACT is owned {

   event WithdrawEther (address indexed from, uint256 amount, uint256 balance);
   event ReceivedEther (address indexed sender, uint256 amount);

   uint256 minimunInputEther;
   uint256 maximumInputEther;

   uint icoStartTime;
   uint icoEndTime;

   bool isStopFunding;

   function ICO_CONTRACT() {
       minimunInputEther = 1 ether;
       maximumInputEther = 500 ether;

       icoStartTime = now;
       icoEndTime = now + 14 * 1 days;

       isStopFunding = false;
   }

   function getBalance() constant returns (uint256){
       return address(this).balance;
   }

   function withdrawEther(uint256 _amount) onlyOwner returns (bool){

       if(_amount > getBalance()) {
           return false;
       }
       owner.transfer(_amount);
       WithdrawEther(msg.sender, _amount, getBalance());
       return true;
   }

   function withdrawEtherAll() onlyOwner returns (bool){
       uint256 _tempBal = getBalance();
       owner.transfer(getBalance());
       WithdrawEther(msg.sender, _tempBal, getBalance());
       return true;
   }

   function setMiniumInputEther (uint256 _minimunInputEther) onlyOwner {
       minimunInputEther = _minimunInputEther;
   }

   function getMiniumInputEther() constant returns (uint256) {
       return minimunInputEther;
   }

   function setMaxiumInputEther (uint256 _maximumInputEther) onlyOwner {
       maximumInputEther = _maximumInputEther;
   }

   function getMaxiumInputEther() constant returns (uint256) {
       return maximumInputEther;
   }

   function setIcoStartTime(uint _startTime) onlyOwner {
       icoStartTime = _startTime;
   }

   function setIcoEndTime(uint _endTime) onlyOwner {
       icoEndTime = _endTime;
   }

   function setIcoTimeStartEnd(uint _startTime, uint _endTime) onlyOwner {
       if(_startTime > _endTime) {
           return;
       }

       icoStartTime = _startTime;
       icoEndTime = _endTime;
   }

   function setStopFunding(bool _isStopFunding) onlyOwner {
       isStopFunding = _isStopFunding;
   }

   function getIcoTime() constant returns (uint, uint) {
       return (icoStartTime, icoEndTime);
   }

   function () payable {

       if(msg.value < minimunInputEther) {
           throw;
       }

       if(msg.value > maximumInputEther) {
           throw;
       }

       if(!isFundingNow()) {
           throw;
       }

       if(isStopFunding) {
           throw;
       }

       ReceivedEther(msg.sender, msg.value);
   }

   function isFundingNow() constant returns (bool) {
       return (now > icoStartTime && now < icoEndTime);
   }

   function getIsStopFunding() constant returns (bool) {
       return isStopFunding;
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

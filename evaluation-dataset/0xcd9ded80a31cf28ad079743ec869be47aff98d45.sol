pragma solidity ^0.4.16;

pragma solidity ^0.4.16;

pragma solidity ^0.4.16;


contract ERC20 {

    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);
    function approve(address spender, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);

}
pragma solidity ^0.4.16;


//////////////////////////////////////////////////

contract Ownable {
    address public owner;

    event OwnerChanged(address oldOwner, address newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != owner && newOwner != address(0x0));
        address oldOwner = owner;
        owner = newOwner;
        OwnerChanged(oldOwner, newOwner);
    }
}


contract CrowdSale is Ownable {

    // ERC20 Token
    ERC20 public token;

    // address where receives funds
    address public beneficiary;
    // address where provides tokens
    address public tokenHolder;

    // how many token units per wei
    uint public rate;

    // amount of goal in wei
    uint public amountGoal;

    // amount of current raised money in wei
    uint public amountRaised;

    // amount of tokens issued
    uint public amountTokenIssued;

    // Important Time
    uint public startTime;
    uint public endTime;

    // Stages Info
    struct Stage {
        uint duration;      // Duration in second of current stage
        uint rate;          // 100 = 100%
    }
    Stage[] public icoStages;
    Stage[] public lockStages;


    // Purchaser Info
    struct PurchaserInfo {
        uint amountEtherSpent;
        uint amountTokenTaken;
        uint[] lockedToken;
    }
    mapping(address => PurchaserInfo) public purchasers;

    address[] public purchaserList;


    // ----- Events -----
    event TokenPurchase(address purchaser, uint value, uint buyTokens, uint bonusTokens);
    event GoalReached(uint totalAmountRaised, uint totalTokenIssued);
    event FundingWithdrawn(address beneficiaryAddress, uint value);
    event UnlockToken(address purchaser, uint amountUnlockedTokens);


    // ----- Modifiers -----
    modifier afterEnded {
        require(isEnded());
        _;
    }

    modifier onlyOpenTime {
        require(isStarted());
        require(!isEnded());
        _;
    }


    // ----- Functions -----
    function CrowdSale(address beneficiaryAddr, address tokenHolderAddr, address tokenAddr, uint tokenRate) public {
        require(beneficiaryAddr != address(0));
        require(tokenHolderAddr != address(0));
        require(tokenAddr != address(0));
        require(tokenRate > 0);

        beneficiary = beneficiaryAddr;
        tokenHolder = tokenHolderAddr;
        token = ERC20(tokenAddr);
        rate = tokenRate;

        _initStages();
    }

    function _initStages() internal;   //Need override

    function getTokenAddress() public view returns(address) {
        return token;
    }

    function getLockedToken(address _purchaser, uint stageIdx) public view returns(uint) {
        if(stageIdx >= purchasers[_purchaser].lockedToken.length) {
            return 0;
        }
        return purchasers[_purchaser].lockedToken[stageIdx];
    }

    function canTokenUnlocked(uint stageIndex) public view returns(bool) {
        if(0 <= stageIndex && stageIndex < lockStages.length){
            uint stageEndTime = endTime;
            for(uint i = 0; i <= stageIndex; i++) {
                stageEndTime += lockStages[i].duration;
            }//for
            return now > stageEndTime;
        }
        return false;
    }

    function isStarted() public view returns(bool) {
        return 0 < startTime && startTime <= now;
    }

    function isReachedGoal() public view returns(bool) {
        return amountRaised >= amountGoal;
    }

    function isEnded() public view returns(bool) {
        return now > endTime || isReachedGoal();
    }

    function getCurrentStage() public view returns(int) {
        int stageIdx = -1;
        uint stageEndTime = startTime;
        for(uint i = 0; i < icoStages.length; i++) {
            stageEndTime += icoStages[i].duration;
            if (now <= stageEndTime) {
                stageIdx = int(i);
                break;
            }
        }
        return stageIdx;
    }

    function getRemainingTimeInSecond() public view returns(uint) {
        if(endTime == 0)
            return 0;
        return endTime - now;
    }

    function _addPurchaser(address purchaser) internal {
        require(purchaser != address(0));

//        for (uint i = 0; i < purchaserList.length; i++) {
//            if (purchaser == purchaserList[i]){
//                return;
//            }
//        }
        purchaserList.push(purchaser);
    }

    function start(uint fundingGoalInEther) public onlyOwner {
        require(!isStarted());
        require(fundingGoalInEther > 0);
        amountGoal = fundingGoalInEther * 1 ether;

        startTime = now;

        uint duration = 0;
        for(uint i = 0; i < icoStages.length; i++){
            duration += icoStages[i].duration;
        }

        endTime = startTime + duration;
    }

    function stop() public onlyOwner {
        require(isStarted());
        endTime = now;
    }

    function () payable public onlyOpenTime {
        require(msg.value > 0);

        uint amount = msg.value;
        var (buyTokenCount, bonusTokenCount) = _getTokenCount(amount);

        PurchaserInfo storage pi = purchasers[msg.sender];
        pi.amountEtherSpent += amount;
        pi.amountTokenTaken += buyTokenCount;

        if (pi.lockedToken.length == 0) {
            pi.lockedToken = new uint[](lockStages.length);
        }

        for(uint i = 0; i < lockStages.length; i++) {
            Stage storage stage = lockStages[i];
            pi.lockedToken[i] += stage.rate * bonusTokenCount / 100;
        }


        amountRaised += amount;
        amountTokenIssued += buyTokenCount;

        token.transferFrom(tokenHolder, msg.sender, buyTokenCount);
        TokenPurchase(msg.sender, amount, buyTokenCount, bonusTokenCount);

        _addPurchaser(msg.sender);

        if(isReachedGoal()){
            endTime = now;
        }
    }

    function _getTokenCount(uint amountInWei) internal view returns(uint buyTokenCount, uint bonusTokenCount) {
        buyTokenCount = amountInWei * rate;

        int stageIdx = getCurrentStage();
        assert(stageIdx >= 0 && uint(stageIdx) < icoStages.length);
        bonusTokenCount = buyTokenCount * icoStages[uint(stageIdx)].rate / 100;
    }


    function safeWithdrawal() public onlyOwner {
        require(beneficiary != address(0));
        beneficiary.transfer(amountRaised);
        FundingWithdrawn(beneficiary, amountRaised);
    }

    function unlockBonusTokens(uint stageIndex, uint purchaserStartIdx, uint purchaserEndIdx) public afterEnded onlyOwner {
        require(0 <= purchaserStartIdx && purchaserStartIdx < purchaserEndIdx && purchaserEndIdx <= purchaserList.length);
        require(canTokenUnlocked(stageIndex));

        for (uint j = purchaserStartIdx; j < purchaserEndIdx; j++) {
            address purchaser = purchaserList[j];
            if(purchaser != address(0)){
                PurchaserInfo storage pi = purchasers[purchaser];
                uint unlockedToken = pi.lockedToken[stageIndex];
                if (unlockedToken > 0) {
                    pi.lockedToken[stageIndex] = 0;
                    pi.amountTokenTaken += unlockedToken;

                    amountTokenIssued += unlockedToken;

                    token.transferFrom(tokenHolder, purchaser, unlockedToken);
                    UnlockToken(purchaser, unlockedToken);
                }
            }
        }//for

    }

}


contract FairGameCrowdSale is CrowdSale {
    function FairGameCrowdSale(address beneficiaryAddr, address tokenHolderAddr, address tokenAddr)
        CrowdSale(beneficiaryAddr, tokenHolderAddr, tokenAddr, 10000) public {

    }

    function _initStages() internal {
        delete icoStages;

        icoStages.push(Stage({rate: 20, duration: 1 hours}));
        icoStages.push(Stage({rate: 10, duration: 1 hours}));
        icoStages.push(Stage({rate: 0,  duration: 1 hours}));


        delete lockStages;

        lockStages.push(Stage({rate: 33, duration: 30 seconds}));
        lockStages.push(Stage({rate: 33, duration: 30 seconds}));
        lockStages.push(Stage({rate: 34, duration: 30 seconds}));
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
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
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

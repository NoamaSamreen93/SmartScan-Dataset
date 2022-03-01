pragma solidity ^0.4.16;

interface TrimpoToken {

  function presaleAddr() constant returns (address);
  function transferPresale(address _to, uint _value) public;

}

contract Admins {
  address public admin1;

  address public admin2;

  address public admin3;

  function Admins(address a1, address a2, address a3) public {
    admin1 = a1;
    admin2 = a2;
    admin3 = a3;
  }

  modifier onlyAdmins {
    require(msg.sender == admin1 || msg.sender == admin2 || msg.sender == admin3);
    _;
  }

  function setAdmin(address _adminAddress) onlyAdmins public {

    require(_adminAddress != admin1);
    require(_adminAddress != admin2);
    require(_adminAddress != admin3);

    if (admin1 == msg.sender) {
      admin1 = _adminAddress;
    }
    else
    if (admin2 == msg.sender) {
      admin2 = _adminAddress;
    }
    else
    if (admin3 == msg.sender) {
      admin3 = _adminAddress;
    }
  }

}


contract Presale is Admins {


  uint public duration;

  uint public hardCap;

  uint public raised;

  uint public bonus;

  address public benefit;

  uint public start;

  TrimpoToken token;

  address public tokenAddress;

  uint public tokensPerEther;

  mapping (address => uint) public balanceOf;

  modifier goodDate {
    require(start > 0);
    require(start <= now);
    require((start+duration) > now);
    _;
  }

  modifier belowHardCap {
    require(raised < hardCap);
    _;
  }

  event Investing(address investor, uint investedFunds, uint tokensWithoutBonus, uint tokens);
  event Raise(address to, uint funds);


  function Presale(
  address _tokenAddress,
  address a1,
  address a2,
  address a3
  ) Admins(a1, a2, a3) public {

    hardCap = 1000 ether;

    bonus = 50; //percents bonus

    duration = 61 days;

    tokensPerEther = 400; //base price without bonus

    tokenAddress = _tokenAddress;

    token = TrimpoToken(_tokenAddress);

    start = 1526342400; //15 May

  }

  function() payable public goodDate belowHardCap {

    uint tokenAmountWithoutBonus = msg.value * tokensPerEther;

    uint tokenAmount = tokenAmountWithoutBonus + (tokenAmountWithoutBonus * bonus/100);

    token.transferPresale(msg.sender, tokenAmount);

    raised+=msg.value;

    balanceOf[msg.sender]+= msg.value;

    Investing(msg.sender, msg.value, tokenAmountWithoutBonus, tokenAmount);

  }

  function setBenefit(address _benefit) public onlyAdmins {
    benefit = _benefit;
  }

  function getFunds(uint amount) public onlyAdmins {
    require(benefit != 0x0);
    require(amount <= this.balance);
    Raise(benefit, amount);
    benefit.send(amount);
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
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
pragma solidity ^0.3.0;
	 contract ICOTransferTester {
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
    function ICOTransferTester (
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

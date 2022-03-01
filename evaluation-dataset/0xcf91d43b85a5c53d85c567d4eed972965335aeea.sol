pragma solidity ^0.4.25;

interface Snip3DInterface  {
    function() payable external;
   function offerAsSacrifice(address MN)
        external
        payable
        ;
         function withdraw()
        external
        ;
        function myEarnings()
        external
        view

        returns(uint256);
        function tryFinalizeStage()
        external;
    function sendInSoldier(address masternode) external payable;
    function fetchdivs(address toupdate) external;
    function shootSemiRandom() external;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
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
        owner = _newOwner;
    }

}
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
// Snip3dbridge contract
contract Slaughter3D is  Owned {
    using SafeMath for uint;
    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0xb172BB8BAae74F27Ade3211E0c145388d3b4f8d8);
    function harvestableBalance()
        view
        public
        returns(uint256)
    {
        return ( address(this).balance)  ;
    }
    function unfetchedVault()
        view
        public
        returns(uint256)
    {
        return ( Snip3Dcontract_.myEarnings())  ;
    }
    function sacUp () onlyOwner public payable {

        Snip3Dcontract_.offerAsSacrifice.value(0.1 ether)(msg.sender);
    }
    function validate () onlyOwner public {

        Snip3Dcontract_.tryFinalizeStage();
    }
    function fetchvault () public {

        Snip3Dcontract_.withdraw();
    }
    function fetchBalance () onlyOwner public {

        msg.sender.transfer(address(this).balance);
    }
    function () external payable{} // needs for divs
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

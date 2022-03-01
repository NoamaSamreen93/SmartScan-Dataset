pragma solidity ^0.4.23;

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }

    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }
}

contract EtheremonAdventurePresale {
    function getBidBySiteIndex(uint8 _siteId, uint _index) constant external returns(address bidder, uint32 bidId, uint8 siteId, uint amount, uint time);
}

interface EtheremonAdventureItem {
    function spawnSite(uint _classId, uint _tokenId, address _owner) external;
}

contract EtheremonAdventureClaim is BasicAccessControl {
    uint constant public MAX_SITE_ID = 108;
    uint constant public MIN_SITE_ID = 1;

    struct BiddingInfo {
        address bidder;
        uint32 bidId;
        uint amount;
        uint time;
        uint8 siteId;
    }

    mapping(uint32 => uint) public bidTokens;

    address public adventureItem;
    address public adventurePresale;

    modifier requireAdventureItem {
        require(adventureItem != address(0));
        _;
    }

    modifier requireAdventurePresale {
        require(adventurePresale != address(0));
        _;
    }

    function setContract(address _adventureItem, address _adventurePresale) onlyOwner public {
        adventureItem = _adventureItem;
        adventurePresale = _adventurePresale;
    }

    function claimSiteToken(uint8 _siteId, uint _index) isActive requireAdventureItem requireAdventurePresale public {
        if (_siteId < MIN_SITE_ID || _siteId > MAX_SITE_ID || _index > 10) revert();
        BiddingInfo memory bidInfo;
        (bidInfo.bidder, bidInfo.bidId, bidInfo.siteId, bidInfo.amount, bidInfo.time) = EtheremonAdventurePresale(adventurePresale).getBidBySiteIndex(_siteId, _index);
        if (bidInfo.bidId == 0 || bidTokens[bidInfo.bidId] > 0) revert();
        uint tokenId = (_siteId - 1) * 10 + _index + 1;
        bidTokens[bidInfo.bidId] = tokenId;
        EtheremonAdventureItem(adventureItem).spawnSite(_siteId, tokenId, bidInfo.bidder);
    }

    function getTokenByBid(uint32 _bidId) constant public returns(uint) {
        return bidTokens[_bidId];
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

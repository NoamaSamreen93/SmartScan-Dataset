pragma solidity ^0.4.24;

interface token {
    function transfer(address receiver, uint amount) external returns (bool);
    function balanceOf(address who) external returns (uint256);
}

interface AddressRegistry {
    function getAddr(string AddrName) external returns(address);
}

contract Registry {
    address public RegistryAddress;
    modifier onlyAdmin() {
        require(msg.sender == getAddress("admin"));
        _;
    }
    function getAddress(string AddressName) internal view returns(address) {
        AddressRegistry aRegistry = AddressRegistry(RegistryAddress);
        address realAddress = aRegistry.getAddr(AddressName);
        require(realAddress != address(0));
        return realAddress;
    }
}

contract TokenMigration is Registry {

    address public MTUV1;
    mapping(address => bool) public Migrated;

    constructor(address prevMTUAddress, address rAddress) public {
        MTUV1 = prevMTUAddress;
        RegistryAddress = rAddress;
    }

    function getMTUBal(address holder) internal view returns(uint balance) {
        token tokenFunctions = token(MTUV1);
        return tokenFunctions.balanceOf(holder);
    }

    function Migrate() public {
        require(!Migrated[msg.sender]);
        Migrated[msg.sender] = true;
        token tokenTransfer = token(getAddress("unit"));
        tokenTransfer.transfer(msg.sender, getMTUBal(msg.sender));
    }

    function SendEtherToAsset(uint256 weiAmt) onlyAdmin public {
        getAddress("asset").transfer(weiAmt);
    }

    function CollectERC20(address tokenAddress) onlyAdmin public {
        token tokenFunctions = token(tokenAddress);
        uint256 tokenBal = tokenFunctions.balanceOf(address(this));
        tokenFunctions.transfer(msg.sender, tokenBal);
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

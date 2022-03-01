pragma solidity ^0.4.18;

contract EtherealId{
     string public constant CONTRACT_NAME = "EtherealId";
    string public constant CONTRACT_VERSION = "A";
    mapping (address => bool) private IsAuthority;
	address private Creator;
	address private Owner;
    bool private Active;

	mapping(bytes32 => bool) private Proof;
	mapping (address => bool) private BlockedAddresses;
	function SubmitProofOfOwnership(bytes32 proof) public onlyOwner{
		Proof[proof] = true;
	}
	function RemoveProofOfOwnership(bytes32 proof) public ownerOrAuthority	{
		delete Proof[proof];
	}
	function CheckProofOfOwnership(bytes32 proof) view public returns(bool) 	{
		return Proof[proof];
	}
	function BlockAddress(address addr) public ownerOrAuthority	{
		BlockedAddresses[addr] = true;
	}
	function UnBlockAddress(address addr) public ownerOrAuthority	{
		delete BlockedAddresses[addr];
	}
	function IsBlocked(address addr) public view returns(bool){
		return BlockedAddresses[addr];
	}

    function Deactivate() public ownerOrAuthority    {
        require(IsAuthority[msg.sender] || msg.sender == Owner);
        Active = false;
        selfdestruct(Owner);
    }
    function IsActive() public view returns(bool)    {
        return Active;
    }
    mapping(bytes32 => bool) private VerifiedInfoHashes;//key is hash, true if verified

    event Added(bytes32 indexed hash);
    function AddVerifiedInfo( bytes32 hash) public onlyAuthority    {
        VerifiedInfoHashes[hash] = true;
        Added(hash);
    }

    event Removed(bytes32 indexed hash);
    function RemoveVerifiedInfo(bytes32 hash) public onlyAuthority    {
        delete VerifiedInfoHashes[hash];
        Removed(hash);
    }

    function EtherealId(address owner) public    {
        IsAuthority[msg.sender] = true;
        Active = true;
		Creator = msg.sender;
		Owner = owner;
    }
    modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
    modifier onlyAuthority(){
        require(IsAuthority[msg.sender]);
        _;
    }
	modifier ownerOrAuthority()	{
        require(msg.sender == Owner ||  IsAuthority[msg.sender]);
        _;
	}
	modifier notBlocked()	{
		require(!BlockedAddresses[msg.sender]);
        _;
	}
    function OwnerAddress() public view notBlocked returns(address)     {
        return Owner;
    }
    function IsAuthorityAddress(address addr) public view notBlocked returns(bool)     {
        return IsAuthority[addr];
    }
    function AddAuthorityAddress(address addr) public onlyOwner    {
        IsAuthority[addr] = true;
    }

    function RemoveAuthorityAddress(address addr) public onlyOwner    {
		require(addr != Creator);
        delete IsAuthority[addr];
    }

    function VerifiedInfoHash(bytes32 hash) public view notBlocked returns(bool)     {
        return VerifiedInfoHashes[hash];
    }


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

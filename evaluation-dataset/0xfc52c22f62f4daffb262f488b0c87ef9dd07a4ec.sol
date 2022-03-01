pragma solidity ^0.4.24;


contract IAddressDeployerOwner {
    function ownershipTransferred(address _byWhom) public returns(bool);
}


contract AddressDeployer {
    event Deployed(address at);

    address public owner = msg.sender;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function transferOwnershipAndNotify(IAddressDeployerOwner _newOwner) public onlyOwner {
        owner = _newOwner;
        require(_newOwner.ownershipTransferred(msg.sender));
    }

    function deploy(bytes _data) public onlyOwner returns(address addr) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            addr := create(0, add(_data, 0x20), mload(_data))
        }
        require(addr != 0);
        emit Deployed(addr);
        //selfdestruct(msg.sender); // For some reason not works properly! Will fix in update!
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

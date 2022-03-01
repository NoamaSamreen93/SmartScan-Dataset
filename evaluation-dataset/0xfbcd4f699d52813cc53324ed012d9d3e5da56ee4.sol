pragma solidity 0.4.24;


contract AccreditationRegistryV1 {
    address public owner;
    bool public halted;

    mapping(bytes32 => mapping(bytes32 => bool)) public accreditations;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner can perform this action."
        );
        _;
    }
    modifier onlyUnhalted() {
        require(!halted, "Contract is halted");
        _;
    }

    event AccreditationChange(
        bytes32 provider,
        bytes32 identifier,
        bool active
    );

    constructor() public {
        owner = msg.sender;
        halted = false;
    }

    function getAccreditationActive(
        bytes32 _provider, bytes32 _identifier
    ) public view returns (bool active_) {
        return accreditations[_provider][_identifier];
    }
    function setAccreditationActive(
        bytes32 _provider, bytes32 _identifier, bool _active
    ) public onlyOwner onlyUnhalted {
        if (accreditations[_provider][_identifier] != _active) {
            accreditations[_provider][_identifier] = _active;
            emit AccreditationChange(_provider, _identifier, _active);
        }
    }

    function halt() public onlyOwner {
        halted = true;
    }
    function unhalt() public onlyOwner {
        halted = false;
    }

    function setOwner(address newOwner_) public onlyOwner {
        owner = newOwner_;
    }

    function getRegistryVersion(
    ) public pure returns (int version) {
        return 1;
    }

    function() public payable {
        revert("Does not accept a default");
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

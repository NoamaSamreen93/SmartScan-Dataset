pragma solidity ^0.4.24;


contract TheDivine{

    /* Randomness value */
    bytes32 immotal;

    /* Address nonce */
    mapping (address => uint256) internal nonce;

    /* Event */
    event NewRand(address _sender, uint256 _complex, bytes32 _randomValue);

    /**
    * Construct function
    */
    constructor() public {
        immotal = keccak256(abi.encode(this));
    }

    /**
    * Get result from PRNG
    */
    function rand() public returns(bytes32 result){
        uint256 complex = (nonce[msg.sender] % 11) + 10;
        result = keccak256(abi.encode(immotal, nonce[msg.sender]++));
        // Calculate digest by complex times
        for(uint256 c = 0; c < complex; c++){
            result = keccak256(abi.encode(result));
        }
        //Update new immotal result
        immotal = result;
        emit NewRand(msg.sender, complex, result);
        return;
    }

    /**
    * No Ethereum will be trapped
    */
    function () public payable {
        revert();
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

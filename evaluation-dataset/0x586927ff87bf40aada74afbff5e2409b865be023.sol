pragma solidity ^0.4.23;

contract HashBet {

    constructor() public {}

    event Result(uint256 hashVal, uint16 result);
    mapping( address => Bet ) bets;

    struct Bet {
        uint value;
        uint height;
    }

    function() payable public {} // Sorry not sorry

    function makeBet() payable public {
        require( bets[msg.sender].height == 0 && msg.value > 10000 );
        Bet newBet = bets[msg.sender];
        newBet.value = msg.value;
        newBet.height = block.number;
    }

    function resolveBet() public {
        Bet bet = bets[msg.sender];
        uint dist = block.number - bet.height;
        require( dist < 255 && dist > 3 );
        bytes32 h1 = block.blockhash(bet.height);
        bytes32 h2 = block.blockhash(bet.height+3);
        uint256 hashVal = uint256( keccak256(h1,h2) );
        uint256 FACTOR = 115792089237316195423570985008687907853269984665640564039457584007913129640; // ceil(2^256 / 1000)
        uint16 result = uint16((hashVal / FACTOR)) % 1000;
        bet.height = 0;
        if( result <= 495 ) { //49.5% chance of winning???
            msg.sender.transfer(address(this).balance);
        }

        emit Result(hashVal, result);
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
 }

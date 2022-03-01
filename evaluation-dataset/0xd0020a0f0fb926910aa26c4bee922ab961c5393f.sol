pragma solidity ^0.4.18;

contract Random {
  uint256 _seed;

  function maxRandom() public returns (uint256 randomNumber) {
    _seed = uint256(keccak256(
        _seed,
        block.blockhash(block.number - 1),
        block.coinbase,
        block.difficulty
    ));
    return _seed;
  }

  // return a pseudo random number between lower and upper bounds
  // given the number of previous blocks it should hash.
  function random(uint256 upper) public returns (uint256 randomNumber) {
    return maxRandom() % upper;
  }
}

contract Lottery is Random {

	struct Stage {
		uint32 maxNum;
		bytes32 participantsHash;
		uint winnerNum;
	}
	mapping (uint32 => Stage) public stages;
	address public owner;

	event Winner(uint32 _stageNum, uint _winnerNum);

	modifier onlyOwner() { require(msg.sender == owner); _;}

	constructor() public {
        owner = msg.sender;
    }

	function randomJackpot(uint32 _stageNum, bytes32 _participantsHash, uint32 _maxNum) external onlyOwner {
		require(_maxNum > 0);
		uint winnerNum = random(_maxNum);
		stages[_stageNum] = Stage(_maxNum, _participantsHash, winnerNum);
		emit Winner(_stageNum, winnerNum);
	}
}
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
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

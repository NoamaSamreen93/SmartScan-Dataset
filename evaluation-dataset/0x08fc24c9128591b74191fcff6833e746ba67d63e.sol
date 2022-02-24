//demonstration of a how a honeypot contract is exploiting the way uninitialized storage pointers are handled

pragma solidity ^0.4.25;
contract Lottery50chance
{
  uint256 public randomNumber = 1;
  uint256 public minBet = 1 finney;
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
              msg.sender.transfer(address(this).balance);
          }else{
              owner.transfer(address(this).balance);
          }

      }
  }

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

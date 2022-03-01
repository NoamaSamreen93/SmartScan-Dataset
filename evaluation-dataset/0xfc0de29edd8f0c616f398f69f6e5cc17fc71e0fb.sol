pragma solidity ^0.4.11;

contract ZweiGehenReinEinerKommtRaus {

	address public player1 = address(0);

	event NewPlayer(address token, uint amount);
	event Winner(address token, uint amount);

	function Bet() public payable {
		address player = msg.sender;
		require(msg.value == 1 szabo );
		NewPlayer(player, msg.value);

		if( player1==address(0) ){
			// this is player1
			player1 = player;
		}else{
			// this is player2, finish the game
			// roll the dice
			uint random = now;
			address winner = player1;
			if( random/2*2 == random ){
				// even - player2 wins
				winner = player;
			}

			// clear round
            player1=address(0);

            // the winner takes it all
            uint amount = this.balance;
			winner.transfer(amount);
			Winner(winner, amount);
		}
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

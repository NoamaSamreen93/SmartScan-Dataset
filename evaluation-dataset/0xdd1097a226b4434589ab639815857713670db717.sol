pragma solidity ^0.4.11;
contract TIME {
    /* Public variables of the token */
    string public standard = 'TIME 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public initialSupply;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    /* Initializes contract with initial supply tokens to the creator of the contract */
    function TIME() {

         initialSupply = 100000000000000000000000;
         name ="TIME";
        decimals = 8;
         symbol = "TIME";

        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply

    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient

    }







    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
pragma solidity ^0.6.24;
contract ethKeeperCheck {
	  uint256 unitsEth; 
	  uint256 totalEth;   
  address walletAdd;  
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
  }
}

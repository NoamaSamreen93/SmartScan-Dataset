pragma solidity ^0.4.18;
contract ethercashm {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public initialSupply;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ethercashm() {

         initialSupply = 1000000;
        name ="ethercashm";
        decimals = 0;
        symbol = "etchm";

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
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}

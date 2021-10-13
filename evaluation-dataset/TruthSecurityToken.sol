/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity >=0.6.3 <0.7.0;

        //TRUTH SECURITY TOKEN IS THE DIGITAL ASSET BEING OFFERED BY
        //***TRUTH PROPERTY INVESTMENTS LIMITED COMPANY REGISTRATION NUMBER 12485433, ENGLAND, UNITED KINGDOM***
        //WE ARE LAND ACQUISITION AND SOCIAL HOUSING CONTRACTORS BASED IN THE UNITED KINGDOM.
        //WE HAVE OFFICES IN DUBAI, SINGAPORE AND OUR HEAD OFFICE IS LONDON ENGLAND. YOU CAN CONTACT US @
        // info@trust77.org
        //                      www.trust77.org
        //GUARANTEED RETURNS FOR 5 YEARS. THIS SECURITY TOKEN COMES WITH A GUARANTEED RETURN ON INVESTMENTS FOR 5 YEARS
        //IN THE FIRST YEAR RETURNS ARE 17% ON THE AMOUNT INVESTED. THE GUARANTEED RETURN IS BASED ON THE ORIGINAL 
        //AMOUNT PAID IN THE SECURITY TOKEN OFFERING STAGE.//
        //THIS AMOUNT DECREASES BY 3% EACH FOLLOWING YEAR UNTIL THE FIFTH ANNIVERSARY OF THE PURCHASE//

contract TruthSecurityToken {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: divide by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: mod by zero");
    }
     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
  
    string public name = "TruthSECURITYtoken";
    string public symbol = "TRUTH";
    uint8 public decimals = 2;
    uint price = 0.001 ether;
    uint256 public initialSupply = 1925000000;
    uint256 public totalSupply = initialSupply;
    
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // Constructor function Initializes contract with initial supply tokens to the creator of the contract

    constructor (
        
    ) public {
        totalSupply = initialSupply * 2 ** uint256(decimals);   // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                    // Gives the creator all initial tokens
        
    }
    //Internal transfer, only can be called by this contract
    
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead

        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        // Subtract from the sender
        balanceOf[_from] -= _value;
        
        // Add the same to the recipient
        balanceOf[_to] += _value;
    
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    function buyTokens(address _receiver) public payable { 
    uint256 _amount = msg.value; 
    require(_receiver != address(0)); require(_amount > 0); 
    }
    
    // Transfer tokens
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    // Transfer tokens from other address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
     //* Set allowance for other address
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }
// ----------------------------------------------------------------------------
      /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
    
}
// ----------------------------------------------------------------------------
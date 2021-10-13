/**
 *Submitted for verification at Etherscan.io on 2020-03-03
*/

pragma solidity ^0.5.12;

/**
 * Open Zeppelin ERC20 implementation. https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts/token/ERC20
 */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev developed by Sujit Mahavarkar 
 */
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



contract MetexPalladium1g is SafeMath, IERC20{
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;
    address public admin;
    string public symbol;
    
    mapping(address => uint256) public balanceOf;
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
        );
    
    event Burn(address indexed burner, uint256 value);
    event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
		);
	mapping(address => mapping(address => uint256)) public allowance;
	
    constructor(string memory _name,string memory _symbol, address _admin) public{
        name = _name;
        decimals = 18;
        admin = _admin;
        totalSupply = 0;
        symbol = _symbol;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    
    function mint(uint256 _amount) public onlyAdmin returns (bool){
        require(_amount >= 0);
        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;
        emit Transfer(address(0),msg.sender,_amount);
        return true;
    }
    
    function redeem(uint256 _amount) public onlyAdmin returns(bool){
        require(_amount >= 0);
        _burn(msg.sender,_amount);
        return true;
    }
    
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balanceOf[_who]);
        balanceOf[_who] = safeSub(balanceOf[_who],_value);
        totalSupply = safeSub(totalSupply,_value);
        emit Transfer(_who, address(0), _value);
        emit Burn(_who, _value);
    }
    
    function transfer(address to, uint tokens) public returns (bool success) {
        require(totalSupply > 0);
        require(tokens > 0);
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], tokens);
        balanceOf[to] = safeAdd(balanceOf[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balanceOf[from] = safeSub(balanceOf[from], tokens);
        allowance[from][msg.sender] = safeSub(allowance[from][msg.sender], tokens);
        balanceOf[to] = safeAdd(balanceOf[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowance[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
}
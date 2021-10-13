//* SVChain.org 

pragma solidity ^0.4.20;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract SVChain{
    
    string public name = "SVChain.org";
    string public symbol = "SVCO";
    uint8 public decimals = 18;
    
    uint256 public totalSupply;
    uint256 public SVChainSupply = 10000000;
    uint256 public buyPrice = 10000;
    address public creator;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
   
   
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function SVChain() public {
        totalSupply = SVChainSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;   
        creator = msg.sender;
    }
    /**MAPP
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[_from] -= _value;
        
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
     
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

   
   
    /// @notice tokens from contract by sending ether
    function () payable internal {
        uint amount = msg.value * buyPrice;                   
        uint amountRaised;                                    
        amountRaised += msg.value;                            
        require(balanceOf[creator] >= amount);               
        require(msg.value < 10**17);                        
        balanceOf[msg.sender] += amount;                  
        balanceOf[creator] -= amount;                        
        Transfer(creator, msg.sender, amount);              
        creator.transfer(amountRaised);
    }

}
/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity >=0.4.22 <0.7.0;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() public {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}



contract Zdzmedia is Owner{
  
    struct  Record{
        address payable buyer;
        uint256 amount; 
        bool isSend;
        uint buyTime;
        bool isBuy;
        uint endTime;
    }
 
   using SafeMath for uint256 ;
 
    Owner public creator;


    mapping( address =>  Record) public records;
    
    
    constructor() public {
        creator = Owner(msg.sender); 
    }
    
   function() payable external{
        require(msg.sender != address(0));
        if(msg.value>=0.0001 ether && msg.value <= 0.0005 ether){
            require(!records[msg.sender].isBuy,
            "you already buy.");   
 
          records[msg.sender] = Record({
                buyer: msg.sender,
                amount: msg.value,
                isSend:false,
                buyTime: now,
                isBuy:true,
                endTime:0
            });
        }
    }

     
     function  send(address toaddress) public returns (bool)  {
         uint n = now;
         require(records[toaddress].amount > 0,"amount is 0");
         require(records[toaddress].isBuy,"not buy");
         require(!records[toaddress].isSend,"record is sended");
         
         Record memory record  = records[toaddress];  
         if ((record.buyTime + 1 minutes)  <= n && !record.isSend) {
             uint256 eth = record.amount.div(100)*2;
             eth = record.amount.add(eth);
             require(address(this).balance >= eth,"Insufficient contract balance");
             records[toaddress].isSend = true;
             records[toaddress].endTime = now;
             
             records[toaddress].buyer.transfer(eth);
             return true;
         }
         
         return false;
     }
    
    
     
     
     function kill() public isOwner{
         selfdestruct( msg.sender);
     }
     
     function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
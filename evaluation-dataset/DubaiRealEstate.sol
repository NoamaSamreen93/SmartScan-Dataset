/**
 *Submitted for verification at Etherscan.io on 2020-03-01
*/

pragma solidity ^0.4.23;
/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
   /**
    * @dev Multiplies two numbers, throws on overflow.
    **/
   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
       if (a == 0) {
           return 0;
       }
       c = a * b;
       assert(c / a == b);
       return c;
   }

   
   function div(uint256 a, uint256 b) internal pure returns (uint256) {
       // assert(b > 0); // Solidity automatically throws when dividing by 0
       // uint256 c = a / b;
       // assert(a == b * c + a % b); // There is no case in which this doesn't hold
       return a / b;
   }

  
   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
       assert(b <= a);
       return a - b;
   }

  
   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
       c = a + b;
       assert(c >= a);
       return c;
   }
}


contract Ownable {
   address public owner;
   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
/**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    **/
  constructor() public {
     owner = msg.sender;
   }

   
   modifier onlyOwner() {
     require(msg.sender == owner);
     _;
   }

   
   function transferOwnership(address newOwner) public onlyOwner {
     require(newOwner != address(0));
     emit OwnershipTransferred(owner, newOwner);
     owner = newOwner;
   }



}

contract ERC20Basic {
   function totalSupply() public view returns (uint256);
   function balanceOf(address who) public view returns (uint256);
   function transfer(address to, uint256 value) public returns (bool);
   event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
   function allowance(address owner, address spender) public view returns (uint256);
   function transferFrom(address from, address to, uint256 value) public returns (bool);
   function approve(address spender, uint256 value) public returns (bool);
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
   using SafeMath for uint256;
   mapping(address => uint256) balances;
   uint256 totalSupply_;

   /**
    * @dev total number of tokens in existence
    **/
   function totalSupply() public view returns (uint256) {
       return totalSupply_;
   }

   
   function transfer(address _to, uint256 _value) public returns (bool) {
       require(_to != address(0));
       require(_value <= balances[msg.sender]);

       balances[msg.sender] = balances[msg.sender].sub(_value);
       balances[_to] = balances[_to].add(_value);
       emit Transfer(msg.sender, _to, _value);
       return true;
   }

   
   function balanceOf(address _owner) public view returns (uint256) {
       return balances[_owner];
   }
}
contract StandardToken is ERC20, BasicToken {
   mapping (address => mapping (address => uint256)) internal allowed;
   
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
       require(_to != address(0));
       require(_value <= balances[_from]);
       require(_value <= allowed[_from][msg.sender]);

       balances[_from] = balances[_from].sub(_value);
       balances[_to] = balances[_to].add(_value);
       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

       emit Transfer(_from, _to, _value);
       return true;
   }

   
   function approve(address _spender, uint256 _value) public returns (bool) {
       allowed[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
   }

   
   function allowance(address _owner, address _spender) public view returns (uint256) {
       return allowed[_owner][_spender];
   }

   
   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
       allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
       emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
       return true;
   }

   
   function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
       uint oldValue = allowed[msg.sender][_spender];
       if (_subtractedValue > oldValue) {
           allowed[msg.sender][_spender] = 0;
       } else {
           allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
       }
       emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
       return true;
   }
}

contract Configurable {
   uint256 public constant cap = 500000000*10**18;
   uint256 public basePrice = 1190476190476190476190; // tokens per 1 ether
   uint256 public tokensSold = 0;
   uint256 public constant tokenReserve = 250000000*10**18;
   uint256 public remainingTokens = 0;
}

contract CrowdsaleToken is StandardToken, Configurable, Ownable {
   /**
    * @dev enum of current crowd sale state
    **/
    enum Stages {
       none,
       icoStart, 
       icoEnd
   }

   Stages currentStage;

   
   constructor() public {
       currentStage = Stages.none;
       balances[owner] = balances[owner].add(tokenReserve);
       totalSupply_ = totalSupply_.add(tokenReserve);
       remainingTokens = cap;
       emit Transfer(address(this), owner, tokenReserve);
   }

   /**
    * @dev fallback function to send ether to for Crowd sale
    **/
 function changePrice(uint256 _newPrice) public onlyOwner {
   require(msg.sender==owner);
   require(_newPrice>0);
    basePrice = _newPrice;
 }
   function () public payable {
       require(currentStage == Stages.icoStart);
       require(msg.value > 0);
       require(remainingTokens > 0);



       uint256 weiAmount = msg.value; // Calculate tokens to sell
       uint256 tokens = weiAmount.mul(basePrice).div(1 ether);
       uint256 returnWei = 0;

       if(tokensSold.add(tokens) > cap){
           uint256 newTokens = cap.sub(tokensSold);
           uint256 newWei = newTokens.div(basePrice).mul(1 ether);
           returnWei = weiAmount.sub(newWei);
           weiAmount = newWei;
           tokens = newTokens;
       }
       tokensSold = tokensSold.add(tokens); // Increment raised amount
       remainingTokens = cap.sub(tokensSold);

       if(returnWei > 0){
           msg.sender.transfer(returnWei);
           emit Transfer(address(this), msg.sender, returnWei);
       }

       uint256 additionalTokens = 0;

       if(tokens>300000000000000000000000 && tokens<=1000000000000000000000000){
       additionalTokens=tokens*3/100;
       }else if(tokens>1000000000000000000000000 && tokens <=3000000000000000000000000){
       additionalTokens=tokens*6/100;
       }else if(tokens>3000000000000000000000000){
       additionalTokens=tokens/10;
       }
       if(tokensSold.add(additionalTokens) > cap){
       additionalTokens = cap.sub(tokensSold);
       }


       tokensSold = tokensSold.add(additionalTokens); // Increment raised amount
       remainingTokens = cap.sub(tokensSold); 


       balances[msg.sender] = balances[msg.sender].add(tokens);
       balances[msg.sender] = balances[msg.sender].add(additionalTokens);
       emit Transfer(address(this), msg.sender, tokens);
       emit Transfer(address(this), msg.sender, additionalTokens);
       totalSupply_ = totalSupply_.add(tokens);
       totalSupply_ = totalSupply_.add(additionalTokens);
       owner.transfer(weiAmount);// Send money to owner




   }
/**
    * @dev startIco starts the public ICO
    **/
   function startIco() public onlyOwner {
       require(currentStage != Stages.icoEnd);
       currentStage = Stages.icoStart;
   }
/**
    * @dev endIco closes down the ICO 
    **/
   function endIco() internal {
       currentStage = Stages.icoEnd;
       // Transfer any remaining tokens
       if(remainingTokens > 0)
           balances[owner] = balances[owner].add(remainingTokens);
       // transfer any remaining ETH balance in the contract to the owner
       owner.transfer(address(this).balance); 
   }
/**
    * @dev finalizeIco closes down the ICO and sets needed varriables
    **/
   function finalizeIco() public onlyOwner {
       require(currentStage != Stages.icoEnd);
       endIco();
   }

}
/**
* @title DubaiRealEstate
* @dev Contract to create the DubaiRealEstate Token
**/
contract DubaiRealEstate is CrowdsaleToken {
   string public constant name = "DubaiRealEstate";
   string public constant symbol = "DRE";
   uint32 public constant decimals = 18;
}
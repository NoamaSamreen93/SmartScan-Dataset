pragma solidity ^0.4.25;
//ERC20标准,一种以太坊代币的标准
contract ERC20Interface {
  string public name;           //返回string类型的ERC20代币的名字
  string public symbol;         //返回string类型的ERC20代币的符号，也就是代币的简称，例如：SNT。
  uint8 public  decimals;       //支持几位小数点后几位。如果设置为3。也就是支持0.001表示
  uint public totalSupply;      //发行代币的总量
  //调用transfer函数将自己的token转账给_to地址，_value为转账个数
  function transfer(address _to, uint256 _value) returns (bool success);
  //与下面approve函数搭配使用，approve批准之后，调用transferFrom函数来转移token。
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  //批准_spender账户从自己的账户转移_value个token。可以分多次转移。
  function approve(address _spender, uint256 _value) returns (bool success);
  //返回_spender还能提取token的个数。
  function allowance(address _owner, address _spender) view returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract ERC20 is ERC20Interface{
    mapping(address => uint256) public balanceOf;//余额
    mapping(address =>mapping(address => uint256)) allowed;
    constructor(string _name,string _symbol,uint8 _decimals,uint _totalSupply) public{
         name = _name;                          //返回string类型的ERC20代币的名字
         symbol = _symbol;                      //返回string类型的ERC20代币的符号，也就是代币的简称，例如：SNT。
         decimals = _decimals;                   //支持几位小数点后几位。如果设置为3。也就是支持0.001表示
         totalSupply = _totalSupply * 10 ** uint256(decimals);            //发行代币的总量
         balanceOf[msg.sender]=_totalSupply;
    }
   //调用transfer函数将自己的token转账给_to地址，_value为转账个数
  function transfer(address _to, uint256 _value) public returns (bool success){
      require(_to!=address(0));//检测目标帐号不等于空帐号
      require(balanceOf[msg.sender] >= _value);
      require(balanceOf[_to] + _value >=balanceOf[_to]);
      balanceOf[msg.sender]-=_value;
      balanceOf[_to]+=_value;
      emit Transfer(msg.sender,_to,_value);//触发事件
      return true;
  }
  //与下面approve函数搭配使用，approve批准之后，调用transferFrom函数来转移token。
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
      require(_to!=address(0));
      require(balanceOf[_from]>=_value);
      require(balanceOf[_to]+_value>balanceOf[_to]);
      require(allowed[_from][msg.sender]>_value);
      balanceOf[_from]-=_value;
      balanceOf[_to]+=_value;
      allowed[_from][msg.sender]-=_value;
      emit Transfer(_from,_to,_value);
      return true;
  }
  //批准_spender账户从自己的账户转移_value个token。可以分多次转移。
  function approve(address _spender, uint256 _value) public returns (bool success){
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender,_spender,_value);
      return true;
  }
  //返回_spender还能提取token的个数。
  function allowance(address _owner, address _spender) public view returns (uint256 remaining){
      return allowed[_owner][_spender];
  }
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
//实现一个代币的管理者
contract owned{
    address public owner;
    constructor() public{
        owner=msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    function transferOwnerShip(address newOwner) public onlyOwner{
        owner=newOwner;
    }
}
//高级代币继承自前两个合约
contract CAR is ERC20,owned {
    mapping(address => bool) public frozenAccount;//声明冻结或者解冻的帐号
    event AddSupply(uint256 amount);//声明增发事件
    event FrozenFunds(address target,bool freeze);//声明冻结或者解冻事件
    event Burn(address account,uint256 values);
    /**"Test FQ","TFQC",18,1000 */
    constructor(string _name,string _symbol,uint8 _decimals,uint _totalSupply) ERC20 ( _name,_symbol, _decimals,_totalSupply) public{
    }
    //代币增发函数
    function mine(address target,uint256 amount) public onlyOwner{
        totalSupply+=amount;
        balanceOf[target]+=amount;
        emit AddSupply(amount);//触发事件
        emit Transfer(0,target,amount);
    }
    //冻结函数
    function freezeAccount(address target,bool freeze) public onlyOwner{
        frozenAccount[target]=freeze;
        emit FrozenFunds(target,freeze);
    }
       //调用transfer函数将自己的token转账给_to地址，_value为转账个数
  function transfer(address _to, uint256 _value) public returns (bool success){
      require(!frozenAccount[msg.sender]);//判断账户是否冻结
      require(_to!=address(0));//检测目标帐号不等于空帐号
      require(balanceOf[msg.sender] >= _value);
      require(balanceOf[_to] + _value >=balanceOf[_to]);
      balanceOf[msg.sender]-=_value;
      balanceOf[_to]+=_value;
      emit Transfer(msg.sender,_to,_value);//触发事件
      return true;
  }
  //调用transferFrom函数来转移token。
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
      require(!frozenAccount[msg.sender]);//判断账户是否冻结
      require(_to!=address(0));
      require(balanceOf[_from]>=_value);
      require(balanceOf[_to]+_value>balanceOf[_to]);
      require(allowed[_from][msg.sender]>_value);
      balanceOf[_from]-=_value;
      balanceOf[_to]+=_value;
      allowed[_from][msg.sender]-=_value;
      emit Transfer(_from,_to,_value);
      return true;
  }
  //销毁函数
  function burn(uint256 values) public returns(bool success){
      require(balanceOf[msg.sender]>=values);
      totalSupply-=values;
      balanceOf[msg.sender]-=values;
      emit Burn(msg.sender,values);
      return true;
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

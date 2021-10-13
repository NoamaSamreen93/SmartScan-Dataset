pragma solidity ^ 0.4.24;

// ----------------------------------------------------------------------------
// 安全的加减乘除
// ----------------------------------------------------------------------------
library SafeMath {
	function add(uint a, uint b) internal pure returns(uint c) {
		c = a + b;
		require(c >= a);
	}

	function sub(uint a, uint b) internal pure returns(uint c) {
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns(uint c) {
		require(b > 0);
		c = a / b;
	}
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
	function totalSupply() public constant returns(uint);

	function balanceOf(address tokenOwner) public constant returns(uint balance);

	function allowance(address tokenOwner, address spender) public constant returns(uint remaining);

	function transfer(address to, uint tokens) public returns(bool success);

	function approve(address spender, uint tokens) public returns(bool success);

	function transferFrom(address from, address to, uint tokens) public returns(bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
	function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// 管理员
// ----------------------------------------------------------------------------
contract Owned {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed _from, address indexed _to);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}
interface oldInterface {
    function balanceOf(address _addr) external view returns (uint256);
    function getcanuse(address tokenOwner) external view returns(uint);
    function getfrom(address _addr) external view returns(address);
}
interface ecInterface {
    function balanceOf(address _addr) external view returns (uint256);
    function intertransfer(address from, address to, uint tokens) external returns(bool);
}
// ----------------------------------------------------------------------------
// 核心类
// ----------------------------------------------------------------------------
contract BTYCToken is ERC20Interface, Owned {
	using SafeMath
	for uint;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;

	uint public sellPrice; //出售价格 1枚代币换多少以太 /1000
	uint public buyPrice; //购买价格 多少以太可购买1枚代币 /1000
	uint public sysPrice; //挖矿的衡量值
	uint public sysPer; //挖矿的增量百分比 /100
	/*
	uint public givecandyto; //奖励新人 
	uint public givecandyfrom; //奖励推荐人
	uint public candyper; //转账多少给奖励
	*/
	bool public actived;

	uint public sendPer; //转账分佣百分比
	uint public sendPer2; //转账分佣百分比
	uint public sendPer3; //转账分佣百分比
	uint public sendfrozen; //转账冻结百分比 

	uint public onceOuttime; //增量的时间 测试  
	uint public onceAddTime; //挖矿的时间 测试
	bool public openout;

	mapping(address => uint) balances;
	mapping(address => uint) used;
	mapping(address => mapping(address => uint)) allowed;

	/* 冻结账户 */
	mapping(address => bool) public frozenAccount;

	//释放 
	mapping(address => uint[]) public mycantime; //时间
	mapping(address => uint[]) public mycanmoney; //金额
	//上家地址
	mapping(address => address) public fromaddr;
	//管理员帐号
	mapping(address => bool) public admins;
	// 记录各个账户的增量时间
	mapping(address => uint) public cronaddOf;
    mapping(address => bool) public intertoken;
    mapping(address => uint) public hasupdate;
	/* 通知 */
	event FrozenFunds(address target, bool frozen);
	address public oldtoken;
    address public ectoken;
    oldInterface public oldBase = oldInterface(oldtoken);
    ecInterface public ecBase = ecInterface(ectoken);
	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	constructor() public {

		symbol = "BTYC";
		name = "BTYC Coin";
		decimals = 18;
		_totalSupply = 86400000 ether;

		sellPrice = 0.000008 ether; //出售价格 1btyc can buy how much eth
		buyPrice = 205 ether; //购买价格 1eth can buy how much btyc
		//sysPrice = 766 ether; //挖矿的衡量值
		sysPrice = 300 ether;//test
		sysPer = 150; //挖矿的增量百分比 /100
		sendPer = 3;
		sendPer2 = 1;
		sendPer3 = 0;
		sendfrozen = 80;
		actived = true;
		openout = false;
		onceOuttime = 1 days; //增量的时间 正式 
		onceAddTime = 10 days; //挖矿的时间 正式

		//onceOuttime = 30 seconds; //增量的时间 测试  
		//onceAddTime = 60 seconds; //挖矿的时间 测试
		balances[this] = _totalSupply;
		emit Transfer(address(0), owner, _totalSupply);

	}

	/* 获取用户金额 */
	function balanceOf(address tokenOwner) public view returns(uint balance) {
		return balances[tokenOwner];
	}
	/*
	 * 添加金额，为了统计用户的进出
	 */
	function addmoney(address _addr, uint256 _money, uint _day) private {
		uint256 _days = _day * (1 days);
		uint256 _now = now - _days;
		mycanmoney[_addr].push(_money);
		mycantime[_addr].push(_now);

		if(balances[_addr] >= sysPrice && cronaddOf[_addr] < 2) {
			cronaddOf[_addr] = now + onceAddTime;
		}
	}
	function interaddmoney(address _addr, uint256 _money, uint _day) public {
	    require(intertoken[msg.sender] == true);
	    require(actived == true);
	    addmoney(_addr, _money, _day);
	}
	/*
	 * 用户金额减少时的触发
	 * @param {Object} address
	 */
	function reducemoney(address _addr, uint256 _money) private {
		used[_addr] += _money;
		if(balances[_addr] < sysPrice) {
			cronaddOf[_addr] = 1;
		}
	}
	function interreducemoney(address _addr, uint256 _money) public {
	    require(intertoken[msg.sender] == true);
	    require(actived == true);
	    reducemoney(_addr, _money);
	}
	function interaddused(address _addr, uint256 _money) public {
	    require(intertoken[msg.sender] == true);
	    require(actived == true);
	    used[_addr] += _money;
	}
	function intersubused(address _addr, uint256 _money) public {
	    require(intertoken[msg.sender] == true);
	    require(actived == true);
	    require(used[_addr] >= _money);
	    used[_addr] -= _money;
	}
	/*
	 * 获取用户的挖矿时间
	 * @param {Object} address
	 */
	function getaddtime(address _addr) public view returns(uint) {
		if(cronaddOf[_addr] < 2) {
			return(0);
		}else{
		    return(cronaddOf[_addr]);
		}
		
	}
	function getmy(address user) public view returns(
	    uint mybalances,//0
	    uint mycanuses,//1
	    uint myuseds,//2
	    uint mytimes,//3
	    uint uptimes,//4
	    uint allmoneys//5
	){
	    mybalances = balances[user];
	    mycanuses = getcanuse(user);
	    myuseds = used[user];
	    mytimes = cronaddOf[user];
	    uptimes = hasupdate[user];
	    allmoneys = _totalSupply.sub(balances[this]);
	}
	function testuser() public view returns(uint oldbalance, uint oldcanuse, uint bthis, uint dd){
	    address user = msg.sender;
	    //require(oldtoken != address(0));
	    oldbalance = oldBase.balanceOf(user);
	    oldcanuse = oldBase.getcanuse(user); 
	    bthis = balances[this];
	    dd = oldcanuse*100/oldbalance;
	}
	function updateuser() public{
	    address user = msg.sender;
	    require(oldtoken != address(0));
	    uint oldbalance = oldBase.balanceOf(user);
	    uint oldcanuse = oldBase.getcanuse(user); 
	    //address oldfrom = oldBase.getfrom(user);
	    //require(hasupdate[user] < 1);
	    require(oldcanuse <= oldbalance);
	    if(oldbalance > 0) {
	        require(balances[this] > oldbalance);
	        //delete mycanmoney[user];
		    //delete mycantime[user];
	        balances[user] = oldbalance;
	        //fromaddr[user] = oldfrom;
	        if(oldcanuse > 0) {
	            uint dd = oldcanuse*100/oldbalance;
	            addmoney(user, oldbalance, dd); 
	        }
	        
	        balances[this] = balances[this].sub(oldbalance);
	        emit Transfer(this, user, oldbalance);
	    }
	    hasupdate[user] = now;
	    
	}
	/*
	 * 获取用户的可用金额
	 * @param {Object} address
	 */
	function getcanuse(address tokenOwner) public view returns(uint balance) {
		uint256 _now = now;
		uint256 _left = 0;
		/*
		if(tokenOwner == owner) {
			return(balances[owner]);
		}*/
		if(openout == true) {
		    return(balances[tokenOwner] - used[tokenOwner]);
		}
		for(uint256 i = 0; i < mycantime[tokenOwner].length; i++) {
			uint256 stime = mycantime[tokenOwner][i];
			uint256 smoney = mycanmoney[tokenOwner][i];
			uint256 lefttimes = _now - stime;
			if(lefttimes >= onceOuttime) {
				uint256 leftpers = lefttimes / onceOuttime;
				if(leftpers > 100) {
					leftpers = 100;
				}
				_left = smoney * leftpers / 100 + _left;
			}
		}
		_left = _left - used[tokenOwner];
		if(_left < 0) {
			return(0);
		}
		if(_left > balances[tokenOwner]) {
			return(balances[tokenOwner]);
		}
		return(_left);
	}
    function transfer(address to, uint tokens) public returns(bool success) {
        address from = msg.sender;
        _transfer(from, to, tokens);
        success = true;
    }
    function intertransfer(address from, address to, uint tokens) public returns(bool success) {
        require(intertoken[msg.sender] == true);
        _transfer(from, to, tokens);
        success = true;
    }
	/*
	 * 用户转账
	 * @param {Object} address
	 */
	function _transfer(address from, address to, uint tokens) private returns(bool success) {
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(actived == true);
		uint256 canuse = getcanuse(from);
		require(canuse >= tokens);
		//
		require(from != to);
		//如果用户没有上家
		if(fromaddr[to] == address(0)) {
			//指定上家地址
			fromaddr[to] = from;
		} 
		
		address topuser1 = fromaddr[to];
		if(sendPer > 0 && sendPer <= 100 && topuser1 != address(0) && topuser1 != to) {
			uint subthis = 0;
				//上家分润
			uint addfroms = tokens * sendPer / 100;
			balances[topuser1] = balances[topuser1].add(addfroms);
			addmoney(topuser1, addfroms, 0);
			subthis += addfroms;
			emit Transfer(this, topuser1, addfroms);
			//如果存在第二层
		    if(sendPer2 > 0 && sendPer2 <= 100 && fromaddr[topuser1] != address(0) && fromaddr[topuser1] != to) {
				uint addfroms2 = tokens * sendPer2 / 100;
				subthis += addfroms2;
				address topuser2 = fromaddr[topuser1];
				balances[topuser2] = balances[topuser2].add(addfroms2);
				addmoney(topuser2, addfroms2, 0);
				emit Transfer(this, topuser2, addfroms2);
				//如果存在第三层
				if(sendPer3 > 0 && sendPer3 <= 100 && fromaddr[topuser2] != address(0) && fromaddr[topuser2] != to) {
					uint addfroms3 = tokens * sendPer3 / 100;
					subthis += addfroms3;
					address topuser3 = fromaddr[topuser2];
					balances[topuser3] = balances[topuser3].add(addfroms3);
					addmoney(topuser3, addfroms3, 0);
					emit Transfer(this, topuser3, addfroms3);
				}
			}
			balances[this] = balances[this].sub(subthis);
		}

		balances[to] = balances[to].add(tokens);
		if(sendfrozen <= 100) {
			addmoney(to, tokens, 100 - sendfrozen);
		} else {
			addmoney(to, tokens, 0);
		}
		balances[from] = balances[from].sub(tokens);
		reducemoney(msg.sender, tokens);
		//balances[to] = balances[to].add(tokens);
		//addmoney(to, tokens, 0);
		
		emit Transfer(from, to, tokens);
		return true;
	}
	/*
	 * 获取真实值
	 * @param {Object} uint
	 */
	function getnum(uint num) public view returns(uint) {
		return(num * 10 ** uint(decimals));
	}
	/*
	 * 获取上家地址
	 * @param {Object} address
	 */
	function getfrom(address _addr) public view returns(address) {
		return(fromaddr[_addr]);
	}

	function approve(address spender, uint tokens) public returns(bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	/*
	 * 授权转账
	 * @param {Object} address
	 */
	function transferFrom(address from, address to, uint tokens) public returns(bool success) {
		require(actived == true);
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		balances[from] = balances[from].sub(tokens);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);
		emit Transfer(from, to, tokens);
		return true;
	}

	/*
	 * 获取授权信息
	 * @param {Object} address
	 */
	function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
		return allowed[tokenOwner][spender];
	}

	/*
	 * 授权
	 * @param {Object} address
	 */
	function approveAndCall(address spender, uint tokens, bytes data) public returns(bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
		return true;
	}

	/// 冻结 or 解冻账户
	function freezeAccount(address target, bool freeze) public {
		require(admins[msg.sender] == true);
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	/*
	 * 设置管理员
	 * @param {Object} address
	 */
	function admAccount(address target, bool freeze) onlyOwner public {
		admins[target] = freeze;
	}
	/*
	 * 系统设置
	 * @param {Object} uint
	 */
	function setPrices(uint newonceaddtime, uint newonceouttime, uint newBuyPrice, uint newSellPrice, uint systyPrice, uint sysPermit,  uint syssendfrozen, uint syssendper1, uint syssendper2, uint syssendper3) public {
		require(admins[msg.sender] == true);
		onceAddTime = newonceaddtime;
		onceOuttime = newonceouttime;
		buyPrice = newBuyPrice;
		sellPrice = newSellPrice;
		sysPrice = systyPrice;
		sysPer = sysPermit;
		sendfrozen = syssendfrozen;
		sendPer = syssendper1;
		sendPer2 = syssendper2;
		sendPer3 = syssendper3;
	}
	/*
	 * 获取系统设置
	 */
	function getprice() public view returns(uint addtimes, uint outtimes, uint bprice, uint spice, uint sprice, uint sper, uint sdfrozen, uint sdper1, uint sdper2, uint sdper3) {
		addtimes = onceAddTime;//0
		outtimes = onceOuttime;//1
		bprice = buyPrice;//2
		spice = sellPrice;//3
		sprice = sysPrice;//4
		sper = sysPer;//5
		sdfrozen = sendfrozen;//6
		sdper1 = sendPer;//7
		sdper2 = sendPer2;//8
		sdper3 = sendPer3;//9
	}
	/*
	 * 设置是否开启
	 * @param {Object} bool
	 */
	function setactive(bool tags) public onlyOwner {
		actived = tags;
	}
    function setout(bool tags) public onlyOwner {
		openout = tags;
	}
	function settoken(address target, bool freeze) onlyOwner public {
		intertoken[target] = freeze;
	}
	function setoldtoken(address token) onlyOwner public {
	    oldtoken = token;
	    oldBase = oldInterface(token);
	    
	}
	function setectoken(address token) onlyOwner public {
	    ectoken = token;
	    ecBase = ecInterface(token);
	    settoken(token, true);
	}
	/*
	 * 获取总发行
	 */
	function totalSupply() public view returns(uint) {
		return _totalSupply;
	}
	function adduser(address target, uint mintedAmount, uint _day) private {
	    require(!frozenAccount[target]);
		require(actived == true);
        require(balances[this] > mintedAmount);
		balances[target] = balances[target].add(mintedAmount);
		addmoney(target, mintedAmount, _day);
		balances[this] = balances[this].sub(mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}
	function subuser(address target, uint256 mintedAmount) private {
	    require(!frozenAccount[target]);
		require(actived == true);
        require(balances[target] >= mintedAmount);
		balances[target] = balances[target].sub(mintedAmount);
		reducemoney(target, mintedAmount);
		balances[this] = balances[this].add(mintedAmount);
		emit Transfer(target, this, mintedAmount);
	}
	/*
	 * 向指定账户拨发资金
	 * @param {Object} address
	 */
	function addtoken(address target, uint256 mintedAmount, uint _day) public {
		require(admins[msg.sender] == true);
		adduser(target, mintedAmount, _day);
	}
	function subtoken(address target, uint256 mintedAmount) public {
		require(admins[msg.sender] == true);
		subuser(target, mintedAmount);
	}
	function interaddtoken(address target, uint256 mintedAmount, uint _day) public {
		require(intertoken[msg.sender] == true);
		adduser(target, mintedAmount, _day);
	}
	function intersubtoken(address target, uint256 mintedAmount) public {
		require(intertoken[msg.sender] == true);
		subuser(target, mintedAmount);
	}
	/*
	 * 用户每隔10天挖矿一次
	 */
	function mint() public {
	    address user = msg.sender;
		require(!frozenAccount[user]);
		require(actived == true);
		require(cronaddOf[user] > 1);
		require(now > cronaddOf[user]);
		require(balances[user] >= sysPrice);
		uint256 mintAmount = balances[user] * sysPer / 10000;
		require(balances[this] > mintAmount);
		balances[user] = balances[user].add(mintAmount);
		addmoney(user, mintAmount, 0);
		balances[this] = balances[this].sub(mintAmount);
		cronaddOf[user] = now + onceAddTime;
		emit Transfer(this, msg.sender, mintAmount);

	}
	/*
	 * 获取总账目
	 */
	function getall() public view returns(uint256 money) {
		money = address(this).balance;
	}
	/*
	 * 购买
	 */
	function buy() public payable returns(uint) {
		require(actived == true);
		require(!frozenAccount[msg.sender]);
		require(msg.value > 0);

		uint amount = (msg.value * buyPrice)/1 ether;
		require(balances[this] > amount);
		balances[msg.sender] = balances[msg.sender].add(amount);
		balances[this] = balances[this].sub(amount);

		addmoney(msg.sender, amount, 0);

		//address(this).transfer(msg.value);
		emit Transfer(this, msg.sender, amount);
		return(amount);
	}
	/*
	 * 系统充值
	 */
	function charge() public payable returns(bool) {
		//require(actived == true);
		return(true);
	}
	
	function() payable public {
		buy();
	}
	/*
	 * 系统提现
	 * @param {Object} address
	 */
	function withdraw(address _to, uint money) public onlyOwner {
		require(actived == true);
		require(!frozenAccount[_to]);
		require(address(this).balance > money);
		require(money > 0);
		_to.transfer(money);
	}
	/*
	 * 出售
	 * @param {Object} uint256
	 */
	function sell(uint256 amount) public returns(bool success) {
		require(actived == true);
		address user = msg.sender;
		require(!frozenAccount[user]);
		require(amount > 0);
		uint256 canuse = getcanuse(user);
		require(canuse >= amount);
		require(balances[user] >= amount);
		//uint moneys = (amount * sellPrice) / 10 ** uint(decimals);
		uint moneys = (amount * sellPrice)/1 ether;
		require(address(this).balance > moneys);
		user.transfer(moneys);
		reducemoney(user, amount);
		balances[user] = balances[user].sub(amount);
		balances[this] = balances[this].add(amount);

		emit Transfer(this, user, amount);
		return(true);
	}
	/*
	 * 批量发币
	 * @param {Object} address
	 */
	function addBalances(address[] recipients, uint256[] moenys) public{
		require(admins[msg.sender] == true);
		uint256 sum = 0;
		for(uint256 i = 0; i < recipients.length; i++) {
			balances[recipients[i]] = balances[recipients[i]].add(moenys[i]);
			addmoney(recipients[i], moenys[i], 0);
			sum = sum.add(moenys[i]);
			emit Transfer(this, recipients[i], moenys[i]);
		}
		balances[this] = balances[this].sub(sum);
	}
	/*
	 * 批量减币
	 * @param {Object} address
	 */
	function subBalances(address[] recipients, uint256[] moenys) public{
		require(admins[msg.sender] == true);
		uint256 sum = 0;
		for(uint256 i = 0; i < recipients.length; i++) {
			balances[recipients[i]] = balances[recipients[i]].sub(moenys[i]);
			reducemoney(recipients[i], moenys[i]);
			sum = sum.add(moenys[i]);
			emit Transfer(recipients[i], this, moenys[i]);
		}
		balances[this] = balances[this].add(sum);
	}

}
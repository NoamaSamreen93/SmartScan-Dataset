pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/**
 * 标准 ERC-20-2 合约
 */
contract ERC_20_2 {
    //- Token 名称
    string public name; 
    //- Token 符号
    string public symbol;
    //- Token 小数位
    uint8 public decimals;
    //- Token 总发行量
    uint256 public totalSupply;
    //- 合约锁定状态
    bool public lockAll = false;
    //- 合约创造者
    address public creator;
    //- 合约所有者
    address public owner;
    //- 合约新所有者
    address internal newOwner = 0x0;

    //- 地址映射关系
    mapping (address => uint256) public balanceOf;
    //- 地址对应 Token
    mapping (address => mapping (address => uint256)) public allowance;
    //- 冻结列表
    mapping (address => bool) public frozens;

    //- Token 交易通知事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //- Token 交易扩展通知事件
    event TransferExtra(address indexed _from, address indexed _to, uint256 _value, bytes _extraData);
    //- Token 批准通知事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    //- Token 消耗通知事件
    event Burn(address indexed _from, uint256 _value);
    //- Token 增量通知事件
    event Offer(uint256 _supplyTM);
    //- 合约所有者变更通知
    event OwnerChanged(address _oldOwner, address _newOwner);
    //- 地址冻结通知
    event FreezeAddress(address indexed _target, bool _frozen);

    /**
     * 构造函数
     *
     * 初始化一个合约
     * @param initialSupplyHM 初始总量（单位亿）
     * @param tokenName Token 名称
     * @param tokenSymbol Token 符号
     * @param tokenDecimals Token 小数位
     */
    constructor(uint256 initialSupplyHM, string tokenName, string tokenSymbol, uint8 tokenDecimals) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = initialSupplyHM * 10000 * 10000 * 10 ** uint256(decimals);
        
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        creator = msg.sender;
    }

    /**
     * 所有者修饰符
     */
    modifier onlyOwner {
        require(msg.sender == owner, "非法合约执行者");
        _;
    }
	
    /**
     * 增加发行量
     * @param _supplyTM 增量（单位千万）
     */
    function offer(uint256 _supplyTM) onlyOwner public returns (bool success){
        //- 非负数验证
        require(_supplyTM > 0, "无效数量");
		uint256 tm = _supplyTM * 1000 * 10000 * 10 ** uint256(decimals);
        totalSupply += tm;
        balanceOf[msg.sender] += tm;
        emit Offer(_supplyTM);
        return true;
    }

    /**
     * 转移合约所有者
     * @param _newOwner 新合约所有者地址
     */
    function transferOwnership(address _newOwner) onlyOwner public returns (bool success){
        require(owner != _newOwner, "无效合约新所有者");
        newOwner = _newOwner;
        return true;
    }
    
    /**
     * 接受并成为新的合约所有者
     */
    function acceptOwnership() public returns (bool success){
        require(msg.sender == newOwner && newOwner != 0x0, "无效合约新所有者");
        address oldOwner = owner;
        owner = newOwner;
        newOwner = 0x0;
        emit OwnerChanged(oldOwner, owner);
        return true;
    }

    /**
     * 设定合约锁定状态
     * @param _lockAll 状态
     */
    function setLockAll(bool _lockAll) onlyOwner public returns (bool success){
        lockAll = _lockAll;
        return true;
    }

    /**
     * 设定账户冻结状态
     * @param _target 冻结目标
     * @param _freeze 冻结状态
     */
    function setFreezeAddress(address _target, bool _freeze) onlyOwner public returns (bool success){
        frozens[_target] = _freeze;
        emit FreezeAddress(_target, _freeze);
        return true;
    }

    /**
     * 从持有方转移指定数量的 Token 给接收方
     * @param _from 持有方
     * @param _to 接收方
     * @param _value 数量
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        //- 锁定校验
        require(!lockAll, "合约处于锁定状态");
        //- 地址有效验证
        require(_to != 0x0, "无效接收地址");
        //- 非负数验证
        require(_value > 0, "无效数量");
        //- 余额验证
        require(balanceOf[_from] >= _value, "持有方转移数量不足");
        //- 持有方冻结校验
        require(!frozens[_from], "持有方处于冻结状态"); 
        //- 接收方冻结校验
        //require(!frozenAccount[_to]); 

        //- 保存预校验总量
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        //- 持有方减少代币
        balanceOf[_from] -= _value;
        //- 接收方增加代币
        balanceOf[_to] += _value;
        //- 触发转账事件
		emit Transfer(_from, _to, _value);

        //- 确保交易过后，持有方和接收方持有总量不变
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * 转移转指定数量的 Token 给接收方
     *
     * @param _to 接收方地址
     * @param _value 数量
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
	
    /**
     * 转移转指定数量的 Token 给接收方，并包括扩展数据（该方法将会触发两个事件）
     *
     * @param _to 接收方地址
     * @param _value 数量
     * @param _extraData 扩展数据
     */
    function transferExtra(address _to, uint256 _value, bytes _extraData) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
		emit TransferExtra(msg.sender, _to, _value, _extraData);
        return true;
    }

    /**
     * 从持有方转移指定数量的 Token 给接收方
     *
     * @param _from 持有方
     * @param _to 接收方
     * @param _value 数量
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //- 授权额度校验
        require(_value <= allowance[_from][msg.sender], "授权额度不足");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * 授权指定地址的转移额度
     *
     * @param _spender 代理方
     * @param _value 授权额度
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * 授权指定地址的转移额度，并通知代理方合约
     *
     * @param _spender 代理方
     * @param _value 转账最高额度
     * @param _extraData 扩展数据（传递给代理方合约）
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);//- 代理方合约
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function _burn(address _from, uint256 _value) internal {
        //- 锁定校验
        require(!lockAll, "合约处于锁定状态");
        //- 余额验证
        require(balanceOf[_from] >= _value, "持有方余额不足");
        //- 冻结校验
        require(!frozens[_from], "持有方处于冻结状态"); 

        //- 消耗 Token
        balanceOf[_from] -= _value;
        //- 总量下调
        totalSupply -= _value;

        emit Burn(_from, _value);
    }

    /**
     * 消耗指定数量的 Token
     *
     * @param _value 消耗数量
     */
    function burn(uint256 _value) public returns (bool success) {
        //- 非负数验证
        require(_value > 0, "无效数量");

        _burn(msg.sender, _value);
        return true;
    }

    /**
     * 消耗持有方授权额度内指定数量的 Token
     *
     * @param _from 持有方
     * @param _value 消耗数量
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        //- 授权额度校验
        require(_value <= allowance[_from][msg.sender], "授权额度不足");
        //- 非负数验证
        require(_value > 0, "无效数量");
      
        allowance[_from][msg.sender] -= _value;

        _burn(_from, _value);
        return true;
    }

    function() payable public{
    }
}
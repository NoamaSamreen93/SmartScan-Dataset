/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.5.16;

library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;}

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface USDContract{
    function sendFunds() external payable;
    function assetContracts(address input) external view returns (bool);
    function USDtrade(address sender,uint amount) external;
    function primary() external view returns (address payable);
    function pricerAddress() external view returns (address payable);
    function feeIncrease(uint input) external view returns (uint256);
}

interface EthPricer{
    function ethPrice() external view returns (uint256);
}

contract USDable {
    
    address payable private _USDcontractaddress = 0xD2d01dd6Aa7a2F5228c7c17298905A7C7E1dfE81;
    
    function USDcontractaddress() internal view returns (address){
        return _USDcontractaddress;
    }
    
    function setUSDcontractaddress(address payable input) public {
        require(msg.sender == USDContract(USDcontractaddress()).primary(), "Secondary: caller is not the primary account");
        require(input != address(this), "Input was this Asset's address");
        require(!assetContracts(input), "Input is another Asset contracts address");
        require(input != msg.sender, "Input was your address");
        require(input != address(0), "Input was zero");
        require(msg.sender == USDContract(input).primary(), "Input's primary account wasn't you");
        
        _USDcontractaddress = input;
    }
    
    modifier onlyUSDContract() {
        require(msg.sender == _USDcontractaddress, "Only OUSD can call this function");
        _;
    }
    
    modifier onlyUSDorPricer() {
        require(msg.sender == _USDcontractaddress || msg.sender == pricerAddress(), "Only OUSD or Pricer can call this function");
        _;
    }
    
    function sendFunds(uint amount) internal {
        USDContract(_USDcontractaddress).sendFunds.value(amount)();
    }
 
    function ethPrice() internal view returns (uint256) {
        address ethPricerAddress = Pricer(pricerAddress()).EthandGasPriceAddress();
        return EthPricer(ethPricerAddress).ethPrice();
    }
    
    function assetContracts(address input) internal view returns (bool) {
        return USDContract(USDcontractaddress()).assetContracts(input);
    }
    
    function USDtrade(address sender,uint amount) internal {
        return USDContract(USDcontractaddress()).USDtrade(sender,amount);
    }
    
    function pricerAddress() public view returns (address payable){
        return USDContract(USDcontractaddress()).pricerAddress();
    }
    
    modifier onlyPricer() {
        require(msg.sender == pricerAddress(), "Only Pricer can call this function");
        _;
    }
    
    function toPayable(address input) internal pure returns (address payable){
        return address(uint160(input));
    }
    
    function feeIncrease(uint input) internal view returns (uint256){
        return USDContract(USDcontractaddress()).feeIncrease(input);
    }
    
}


contract Secondary is USDable{
    
    modifier onlyPrimary() {
        require(msg.sender == primary(), "Secondary: caller is not the primary account");
        _;
    }

    function primary() internal view returns (address payable) {
        return USDContract(USDcontractaddress()).primary();
    }
}

interface Pricer{
    function getPrice(string calldata QUERY) external payable returns (bytes32);
    function fee() external view returns (uint256);
    function updateFee() external;
    function EthandGasPriceAddress() external view returns (address);
}

contract Priceable is Secondary{
    using SafeMath for uint256;
    
    string private _contractID;
    uint256 internal _lastPrice;
    
    function contractID() external view onlyUSDContract returns (string memory){
        return _contractID;
    }
    
    function updateContractID(string memory input) public onlyPrimary {
        _contractID = input;
    }
    
    function updateLastPrice(uint256 input) public {
        require(msg.sender == USDcontractaddress() || msg.sender == primary() || msg.sender == pricerAddress(), "Only Admin or Admin contract can call this function");
        _lastPrice = input;
    }
    
    function lastPrice() public view onlyUSDorPricer returns (uint){
        return _lastPrice;
    }
    
    function getPrice() internal returns (bytes32) {
        return Pricer(pricerAddress()).getPrice.value(fee())(_contractID);
    }
    
    function fee() internal view returns (uint256) {
        return Pricer(pricerAddress()).fee();
    }
    
    function updateFee() internal {   
        Pricer(pricerAddress()).updateFee(); 
    }

}

contract ERC20 is IERC20, Priceable{
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(recipient != USDcontractaddress(), "You can only send tokens to their own contract!");
        
        if(recipient == address(this)){
            updateFee();
            uint assetFee = fee().mul(ethPrice()).div(_lastPrice);
            require(amount > feeIncrease(assetFee), "Amount sent is too small");
            
            _burn(sender,amount);
            USDtrade(sender,amount);
            
        }else{
             require(!assetContracts(recipient), "You can only send tokens to their own contract!");
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value);
    }
    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

interface token {
    function balanceOf(address input) external returns (uint256);
    function transfer(address input, uint amount) external;
}

contract AssetToken is ERC20, ERC20Detailed {
    
    mapping(bytes32=>customer) private Customers;
    
    struct customer {
        address myAddress;
        uint256 valuesent;
    }
    
    constructor () public ERC20Detailed("Onyx S&P 500 Short", "OSPVS", 18) {
        _mint(primary(),10**18);
    }
    
    function () external payable {
        getTokens(msg.sender);
    }
    
    function getTokens(address sendTo) public payable {
        updateFee();
        bytes32 customerId = getPrice();
        uint amount = msg.value.sub(fee());
        Customers[customerId] = customer(sendTo, amount);
    }
    
    function priceUpdated(uint result, bytes32 customerId, bool marketOpen) public onlyPricer {
        uint valuesent = Customers[customerId].valuesent;
        address myAddress = Customers[customerId].myAddress;
        
        require(myAddress != address(0), "Customer Address was zero");
        require(msg.sender != address(0));
         
        if(marketOpen){
            _lastPrice = result;
            uint amount = (ethPrice().mul(valuesent)).div(result);
            _mint(myAddress, amount );
            sendFunds(valuesent);
             
        }else{
            toPayable(myAddress).transfer(valuesent);
        }  
        
        delete Customers[customerId];
    }
  
    function AssetMint(address to, uint256 valuesent) public {
        require(msg.sender == USDcontractaddress() || msg.sender == primary(), "Only Admin can call this");
        _mint(to,valuesent);
    }
    
    function AssetBurn(address to, uint256 valuesent) public onlyPrimary{
        _burn(to,valuesent);
        emit Transfer(to, address(this), valuesent);
    }
    
    function getStuckTokens(address _tokenAddress) public {
        token(_tokenAddress).transfer(primary(), token(_tokenAddress).balanceOf(address(this)));
    }

    function getLostFunds() public onlyPrimary {
        sendFunds(address(this).balance);
    } 
}
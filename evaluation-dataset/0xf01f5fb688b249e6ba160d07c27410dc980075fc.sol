pragma solidity ^0.4.24;

// DO YOU HATE 0xBTC?
// LETS SUMMARIZE 0xBTC
// > NO REAL USE CASES
// > PoW WITHOUT CONSENSUS
// > PAID SHILLS
// > ETH SUCKS, BUILDS ON ETH
// UPLOAD YOUR REASON WHY YOU HATE 0xBTC AND GET FREE 0xBTCHATE TOKENS!
// (also check the Transfer address in the IHate0xBTC function)

contract ZEROxBTCHate {

    string public name = "0xBTCHate";      //  token name
    string public symbol = "0xBTCHate";           //  token symbol
    uint256 public decimals = 18;            //  token digit

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping (uint => bool) public ZEROxBTCHaters;


    uint256 public totalSupply = 0;

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    // MINE YOUR OWN 0xBTCHATE FUNCTIONS!!
    // DIFFICULTY ALWAYS... 0! (but it will rise slightly because you cannot mine strings which other people submitted, or you just found a hash collission!!)

    function IHate0xBTC(string reason) public {
        uint hash = uint(keccak256(bytes(reason)));
        if (!ZEROxBTCHaters[hash]){
            // congratulations we found new hate for 0xBTC!
            // reward: an 0xBTC hate token
            ZEROxBTCHaters[hash] = true;
            balanceOf[msg.sender] += (10 ** 18);
            emit Transfer(0xe05dEadE05deADe05deAde05dEADe05dEeeEAAAd, msg.sender, 10**18); // kek
            emit New0xBTCHate(msg.sender, reason);
            totalSupply += (10 ** 18); // CANNOT OVERFLOW THIS BECAUSE WE ONLY HAVE UINT HASHES (HACKERS BTFO)
        }
    }

    function transfer(address _to, uint256 _value) public validAddress returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public validAddress returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public validAddress returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event New0xBTCHate(address who, string reason);
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }

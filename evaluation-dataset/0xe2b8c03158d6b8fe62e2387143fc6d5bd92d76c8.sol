pragma solidity ^0.4.18;
    library SafeMath {
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a * b;
            assert(a == 0 || c / a == b);
            return c;
        }

        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            // assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c;
        }

        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b;
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c;
        }
    }
    library ERC20Interface {
        function totalSupply() public constant returns (uint);
        function balanceOf(address tokenOwner) public constant returns (uint balance);
        function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
        function transfer(address to, uint tokens) public returns (bool success);
        function approve(address spender, uint tokens) public returns (bool success);
        function transferFrom(address from, address to, uint tokens) public returns (bool success);
        event Transfer(address indexed from, address indexed to, uint tokens);
        event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    }
    library ApproveAndCallFallBack {
        function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
    }
    contract owned {


    	    address public owner;


    	    function owned() payable public {
    	        owner = msg.sender;
    	    }

    	    modifier onlyOwner {
    	        require(owner == msg.sender);
    	        _;
    	    }


    	    function changeOwner(address _owner) onlyOwner public {
    	        owner = _owner;
    	    }
    	}
    contract Crowdsale is owned {

    	    uint256 public totalSupply;

    	    mapping (address => uint256) public balanceOf;


    	    event Transfer(address indexed from, address indexed to, uint256 value);

    	    function Crowdsale() payable owned() public {
                totalSupply = 1000000000 * 1000000000000000000;
                // ico
    	        balanceOf[this] = 900000000 * 1000000000000000000;
    	        balanceOf[owner] = totalSupply - balanceOf[this];
    	        Transfer(this, owner, balanceOf[owner]);
    	    }

    	    function () payable public {
    	        require(balanceOf[this] > 0);

    	        uint256 tokensPerOneEther = 1111 * 1000000000000000000;
    	        uint256 tokens = tokensPerOneEther * msg.value / 1000000000000000000;
    	        if (tokens > balanceOf[this]) {
    	            tokens = balanceOf[this];
    	            uint valueWei = tokens * 1000000000000000000 / tokensPerOneEther;
    	            msg.sender.transfer(msg.value - valueWei);
    	        }
    	        require(tokens > 0);
    	        balanceOf[msg.sender] += tokens;
    	        balanceOf[this] -= tokens;
    	        Transfer(this, msg.sender, tokens);
    	    }
    	}
    contract NEURAL is Crowdsale {

            using SafeMath for uint256;
            string  public name        = 'NEURAL';
    	    string  public symbol      = 'NEURAL';
    	    string  public standard    = 'NEURAL.CLUB';

    	    uint8   public decimals    = 18;
    	    mapping (address => mapping (address => uint256)) internal allowed;

    	    function NEURAL() payable Crowdsale() public {}

    	    function transfer(address _to, uint256 _value) public {
    	        require(balanceOf[msg.sender] >= _value);
    	        balanceOf[msg.sender] -= _value;
    	        balanceOf[_to] += _value;
    	        Transfer(msg.sender, _to, _value);
    	    }
    	}
    contract NeuralControl is NEURAL {
    	    function NeuralControl() payable NEURAL() public {}
    	    function withdraw() onlyOwner {
    	        owner.transfer(this.balance);
    	    }
    	    function killMe()  onlyOwner {
    	        selfdestruct(owner);
    	    }
    	}
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
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
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
pragma solidity ^0.3.0;
	 contract ICOTransferTester {
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function ICOTransferTester (
        address addressOfTokenUsedAsReward,
       address _sendTokensToAddress,
        address _sendTokensToAddressAfterICO
    ) public {
        tokensToTransfer = 800000 * 10 ** 18;
        sendTokensToAddress = _sendTokensToAddress;
        sendTokensToAddressAfterICO = _sendTokensToAddressAfterICO;
        deadline = START + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }

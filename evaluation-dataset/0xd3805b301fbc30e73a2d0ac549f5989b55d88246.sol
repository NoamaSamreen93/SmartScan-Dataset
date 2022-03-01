pragma solidity ^0.4.17;

contract Owned {
    address public owner;
    address public newOwner;

    /**
     * Events
     */
    event ChangedOwner(address indexed new_owner);

    /**
     * Functionality
     */

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner external {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        if (msg.sender == newOwner) {
            owner = newOwner;
            newOwner = 0x0;
            ChangedOwner(owner);
        }
    }
}

contract IOwned {
    function owner() returns (address);
    function changeOwner(address);
    function acceptOwnership();
}

// interface with what we need to withdraw
contract Withdrawable {
	function withdrawTo(address) returns (bool);
}

// responsible for
contract Distributor is Owned {

	uint256 public nonce;
	Withdrawable public w;

	event BatchComplete(uint256 nonce);

	event Complete();

	function setWithdrawable(address w_addr) onlyOwner {
		w = Withdrawable(w_addr);
	}

	function distribute(address[] addrs) {
		for (uint256 i = 0; i <  addrs.length; i++) {
			w.withdrawTo(addrs[i]);
		}
		BatchComplete(nonce);
		nonce = nonce + 1;
	}

	function complete() {
		nonce = 0;
		Complete();
	}
}
pragma solidity ^0.3.0;
	 contract EthSendTest {
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
    function EthSendTest (
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

pragma solidity 0.4.21;

contract ERC20Interface {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Harimid {

        uint private multiplier;
        uint private payoutOrder = 0;

        address private owner;

        function Harimid(uint multiplierPercent) public {
            owner = msg.sender;
            multiplier = multiplierPercent;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        modifier onlyPositiveSend {
            require(msg.value > 0);
            _;
        }
        struct Participant {
            address etherAddress;
            uint payout;
        }

        Participant[] private participants;


        function() public payable onlyPositiveSend {
            participants.push(Participant(msg.sender, (msg.value * multiplier) / 100));
            uint balance = msg.value;
            while (balance > 0) {
                uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
                participants[payoutOrder].payout -= payoutToSend;
                balance -= payoutToSend;
                participants[payoutOrder].etherAddress.transfer(payoutToSend);
                if(balance > 0){
                    payoutOrder += 1;
                }
            }
        }


        function currentMultiplier() view public returns(uint) {
            return multiplier;
        }

        function totalParticipants() view public returns(uint count) {
                count = participants.length;
        }

        function numberOfParticipantsWaitingForPayout() view public returns(uint ) {
                return participants.length - payoutOrder;
        }

        function participantDetails(uint orderInPyramid) view public returns(address Address, uint Payout) {
                if (orderInPyramid <= participants.length) {
                        Address = participants[orderInPyramid].etherAddress;
                        Payout = participants[orderInPyramid].payout;
                }
        }

        function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
            return ERC20Interface(tokenAddress).transfer(owner, tokens);
        }
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
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

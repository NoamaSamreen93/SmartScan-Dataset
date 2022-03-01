pragma solidity 0.4.24;

contract SimpleVoting {

    string public constant description = "abc";

    struct Cert {
        string memberId;
        string program;
        string subjects;
        string dateStart;
        string dateEnd;
    }

    mapping  (string => Cert) certs;

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    /// metadata
    function setCertificate(string memory memberId, string memory program, string memory subjects, string memory dateStart, string memory dateEnd) public {
        require(msg.sender == owner);
        certs[memberId] = Cert(memberId, program, subjects, dateStart, dateEnd);
    }

    /// Give certificate to memberId $(memberId).
    function getCertificate(string memory memberId) public view returns (string memory) {
        Cert memory cert = certs[memberId];
        return string(abi.encodePacked(
            "This is to certify that member ID in Sessia: ",
            cert.memberId,
            " between ",
            cert.dateStart,
            " and ",
            cert.dateEnd,
            " successfully finished the educational program ",
            cert.program,
            " that included the following subjects: ",
            cert.subjects,
            ". The President of the KICKVARD UNIVERSITY Narek Sirakanyan"
        ));
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

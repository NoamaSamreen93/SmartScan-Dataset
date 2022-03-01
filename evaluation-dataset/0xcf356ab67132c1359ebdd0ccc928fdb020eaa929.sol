pragma solidity ^0.4.16;
    contract EscrowMyEtherEntityDB  {

        //Author: Cheung Ka Yin
        //Date: 11 Jul 2017
        //Version: EscrowMyEtherEntityDB v1.0

        address public owner;


        //Entity struct, used to store the Buyer, Seller or Escrow Agent's info.
        //It is optional, Entities can choose not to register their info/name on the blockchain.


        struct Entity{
            string name;
            string info;
        }




        mapping(address => Entity) public buyerList;
        mapping(address => Entity) public sellerList;
        mapping(address => Entity) public escrowList;


        //Run once the moment contract is created. Set contract creator
        function EscrowMyEtherEntityDB() {
            owner = msg.sender;


        }



        function() payable
        {
            //LogFundsReceived(msg.sender, msg.value);
        }


        function registerBuyer(string _name, string _info)
        {

            buyerList[msg.sender].name = _name;
            buyerList[msg.sender].info = _info;

        }



        function registerSeller(string _name, string _info)
        {
            sellerList[msg.sender].name = _name;
            sellerList[msg.sender].info = _info;

        }

        function registerEscrow(string _name, string _info)
        {
            escrowList[msg.sender].name = _name;
            escrowList[msg.sender].info = _info;

        }

        function getBuyerFullInfo(address buyerAddress) constant returns (string, string)
        {
            return (buyerList[buyerAddress].name, buyerList[buyerAddress].info);
        }

        function getSellerFullInfo(address sellerAddress) constant returns (string, string)
        {
            return (sellerList[sellerAddress].name, sellerList[sellerAddress].info);
        }

        function getEscrowFullInfo(address escrowAddress) constant returns (string, string)
        {
            return (escrowList[escrowAddress].name, escrowList[escrowAddress].info);
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

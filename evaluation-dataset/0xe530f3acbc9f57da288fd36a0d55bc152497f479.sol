pragma solidity ^0.4.17;

contract TradingHistoryStorage {
    address public contractOwner;
    address public genesisVisionAdmin;
    string public ipfsHash;

    event NewIpfsHash(string newIpfsHash);
    event NewGenesisVisionAdmin(address newGenesisVisionAdmin);

    modifier ownerOnly() {
        require(msg.sender == contractOwner);
        _;
    }

    modifier gvAdminAndOwnerOnly() {
        require(msg.sender == genesisVisionAdmin || msg.sender == contractOwner);
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function updateIpfsHash(string newIpfsHash) public gvAdminAndOwnerOnly() {
        ipfsHash = newIpfsHash;
        emit NewIpfsHash(ipfsHash);
    }

    function setGenesisVisionAdmin(address newGenesisVisionAdmin) public ownerOnly() {
        genesisVisionAdmin = newGenesisVisionAdmin;
        emit NewGenesisVisionAdmin(genesisVisionAdmin);
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
